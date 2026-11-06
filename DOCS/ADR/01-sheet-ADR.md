# Architecture Decision: Sheet Convention

> Purpose: context transfer. Extends the main ADR (Cattle Weight iOS App). Same language rule: all code, comments, UI strings, and docs are written in English.
> Scope: how sheets and full-screen covers are declared, presented, wired, and how they return results to the caller.

---

## 1. Core Decisions

| # | Decision | Rationale |
|---|---|---|
| 1 | Sheets are **centralized**: one `AppSheet` enum, one `AppCoordinator.sheet`, one `.sheet(item:)` | Same idea as `path` for navigation; flow lives in one place |
| 2 | `.sheet(item:)` is attached **once**, on `MainTabView` (the root of the main phase) | Avoids multiple competing presentations and per-view sheet state |
| 3 | `AppSheet` cases **carry their input and result closures** | The caller never references the sheet view, so modules stay decoupled |
| 4 | Sheet content is built by `AppSheetView` in `App/`, using `DIContainer` factories | Coordinator knows no DI and no views; `MainTabView` stays thin |
| 5 | The **coordinator wraps dismissal**, callers do not call `dismissSheet()` themselves | Dismiss logic exists once, not in every call site |
| 6 | Result handling (state changes) lives in the **caller's ViewModel**, not in `App/*` | `App/*` only wires; it must not contain feature logic |
| 7 | **Full-screen covers follow the same rules** but use their own enum, `AppCover`, with its own `AppCoordinator.cover` and `.fullScreenCover(item:)` | Covers and sheets differ in presentation and lifecycle; separate enums keep each one small and let both be shown independently |

---

## 2. File Locations

| Thing | Location |
|---|---|
| `AppSheet` enum | `App/AppSheet.swift` |
| `AppCoordinator.sheet`, `showXSheet(...)`, `dismissSheet()` | `App/AppCoordinator.swift` |
| `AppSheetView` (switch over `AppSheet`, builds views) | `App/AppSheetView.swift` |
| `.sheet(item:)` and `.fullScreenCover(item:)` | `App/MainTabView.swift` |
| `AppCover` enum | `App/AppCover.swift` |
| `AppCoverView` (switch over `AppCover`, builds views) | `App/AppCoverView.swift` |
| Sheet View and ViewModel | `Modules/<Feature>/View/` and `Modules/<Feature>/ViewModel/` |
| Model shared by caller and sheet (for example `ConfigOption`) | `Core/Contracts/` |

---

## 3. Rules

1. A module **never** references a sheet view of another module. It only receives an intent closure from `App/*`.
2. `AppSheet` is `Identifiable` only. It is **not** `Hashable` because cases carry closures.
3. Every case defines a stable `id` string.
4. The sheet ViewModel receives its inputs and callbacks through `init` (cheap, per main ADR §6). It is created by a `DIContainer` factory, never inside the view.
5. One sheet is shown at a time. If a second request arrives while one is open, it is ignored or replaces the first (decided per case in the coordinator).
6. Closure types for the same sheet must match end to end (case, coordinator method, ViewModel, caller). Do not mix `String` and `[String]`.

---

## 4. Implementation

### 4.1 `AppSheet`

```swift
enum AppSheet: Identifiable {
    case examplePicker(current: String, onSelect: (String) -> Void)

    var id: String {
        switch self {
        case .examplePicker: "examplePicker"
        }
    }
}
```

### 4.2 `AppCoordinator`

```swift
@Observable @MainActor
final class AppCoordinator {
    var sheet: AppSheet?

    func showExamplePicker(current: String,
                           onSelect: @escaping (String) -> Void) {
        sheet = .examplePicker(current: current) { [weak self] value in
            onSelect(value)
            self?.dismissSheet()
        }
    }

    func dismissSheet() { sheet = nil }
}
```

Dismissal is wrapped here once. For a sheet that must update the caller live without closing (configuration or setup forms), the case carries both `onSelect` and `onDone`, and only `onDone` dismisses.

### 4.3 `AppSheetView`

```swift
struct AppSheetView: View {
    let sheet: AppSheet
    let container: DIContainer

    var body: some View {
        switch sheet {
        case .examplePicker(let current, let onSelect):
            ExamplePickerSheetView(
                viewModel: container.makeExamplePickerSheetViewModel(
                    current: current,
                    onSelect: onSelect
                )
            )
        }
    }
}
```

### 4.4 `MainTabView`

```swift
TabView { /* tabs */ }
    .sheet(item: $coordinator.sheet) {
        AppSheetView(sheet: $0, container: container)
    }
```

`MainTabView` has `@Bindable var coordinator` because it needs `$coordinator.sheet`.

### 4.5 Caller side (module)

The module declares a closure in its navigation struct. It does not know which sheet opens.

```swift
struct HomeNavigation {
    var onExamplePickerTap: (_ current: String,
                             _ onSelect: @escaping (String) -> Void) -> Void = { _, _ in }
}
```

```swift
@Observable @MainActor
final class HomeViewModel {
    private(set) var selectedExample = "Sapi 1"
    private let navigation: HomeNavigation

    init(navigation: HomeNavigation) { self.navigation = navigation }

    func examplePickerTapped() {
        navigation.onExamplePickerTap(selectedExample) { [weak self] selected in
            self?.selectedExample = selected
        }
    }
}
```

The flow view wires it: `HomeNavigation(onExamplePickerTap: coordinator.showExamplePicker)`.

The view only calls `viewModel.examplePickerTapped()`. No `print` or state mutation belongs in `MainTabView`.

### 4.6 Flow summary

```
Caller View -> ViewModel.intent() -> navigation.onXTap(current, onSelect)
    -> AppCoordinator.showX(...)  (sets sheet, wraps dismiss)
    -> MainTabView .sheet(item:) -> AppSheetView -> container.makeXSheetViewModel(...)
    -> user picks -> onSelect(value) -> caller ViewModel updates state -> sheet dismissed
```

### 4.7 Full-screen cover (`AppCover`)

Same pattern as sheets, applied to a separate enum. Rules 1 to 6 in section 3 apply unchanged.

```swift
enum AppCover: Identifiable {
    case scanSession(onFinish: (ScanResult) -> Void)

    var id: String {
        switch self {
        case .scanSession: "scanSession"
        }
    }
}
```

```swift
// AppCoordinator
var cover: AppCover?

func showScanSession(onFinish: @escaping (ScanResult) -> Void) {
    cover = .scanSession { [weak self] result in
        onFinish(result)
        self?.dismissCover()
    }
}

func dismissCover() { cover = nil }
```

```swift
// MainTabView
.fullScreenCover(item: $coordinator.cover) {
    AppCoverView(cover: $0, container: container)
}
```

`AppCoverView` mirrors `AppSheetView` and builds the view through `DIContainer` factories.

Notes:
- A cover usually has no swipe-to-dismiss, so it must always expose an explicit close action that calls the dismiss closure.
- Covers and sheets are independent. Do not present both at the same time. If a cover must open a sheet, decide that case explicitly (see Open Questions).

---

## 5. Previews

- Sheet views preview with a ViewModel built from mocks and no-op closures: `ExamplePickerSheetViewModel(current: "Sapi 1", onSelect: { _ in })`.
- Caller views preview with `HomeNavigation()`; its default closures are no-ops.

---

## 6. Known Trade-offs

- `AppSheet` cases carry closures, so they cannot be `Hashable` or `Equatable`.
- `AppSheet` grows with every sheet. If it gets large, group by area (`HomeSheet`, `ScanSheet`) or introduce child coordinators.
- Closures capturing a ViewModel can create retain cycles; use `[weak self]`.
- Single `.sheet(item:)` means no stacked sheets. A sheet that opens another sheet needs a separate decision.
- Sheets that need only one trivial local state (for example a confirmation) may stay local with `.sheet(isPresented:)` inside the owning view, to avoid over-engineering. Use the central convention when the sheet is opened from 2+ modules or returns data.

---

## 7. Open Questions

- Should sheets with many fields share one `@Observable` draft object in `Core/Contracts/` instead of one closure per field?
- Can a sheet be opened from inside a full-screen cover? SwiftUI presents it from the cover's own hierarchy, so `.sheet(item:)` attached to `MainTabView` may not work there. Decide when the first case appears.
- How should sheets presented from the Splash phase (before `MainTabView` exists) be handled?
