# Architecture Decision: Push Navigation and List State

> Purpose: context transfer. Extends the main ADR (Cattle Weight iOS App), alongside `01-sheet-ADR.md`. Same language rule: all code, comments, UI strings, and docs are written in English.
> Scope: how pushed screens are declared, requested, built, and how they return results to the caller; plus where list/filter state lives and when ViewModel instances are shared.

---

## 1. Core Decisions

| # | Decision | Rationale |
|---|---|---|
| 1 | Push navigation is **centralized**: all destinations are `AppRoute` cases, pushed through `AppCoordinator` intent methods onto `path: [AppRoute]` | Same idea as sheets in ADR 01; flow lives in one place |
| 2 | Modules **never push themselves**. They receive intent closures from `App/*` (for example `onAddCattleTap`) and call those | Modules stay decoupled; only `App/*` knows the route graph |
| 3 | Route destinations are built in `MainTabView`'s `navigationDestination(for: AppRoute.self)` switch, using `DIContainer` factories | `App/*` is the composer; no other layer builds destination views |
| 4 | No local `@State` booleans with `.navigationDestination(isPresented:)` for feature screens | Per-view navigation state duplicates what `path` already owns and bypasses the coordinator |
| 5 | **List/filter state lives in the ViewModel**: filter selections, sort direction, and derived values (`filteredItems`, `listSubtitle`, `hasNoVisibleCattle`) are `@Observable` state and computed properties on the ViewModel | Views are pure presentation; the derived list cannot drift out of sync with the raw list |
| 6 | View-local `@State` is reserved for **pure UI presentation state** (for example `isFilterPresented`), and binds to ViewModel state via inline `@Bindable` when a child view needs bindings | Sheet open/close is presentation, not feature state |
| 7 | When a pushed screen **mutates data shown by its parent** (for example the add-cattle form), `App/*` creates **one shared ViewModel instance** and passes it to both parent and destination | `@Observable` instances do not sync each other; sharing keeps the list fresh without manual reloads |
| 8 | Fresh per-destination ViewModel instances are used when **no sync is needed** (for example `CattlesDetailView` reads by id) | Avoids unnecessary coupling and keeps instances independent |
| 9 | Data transformation (for example `UIImage` → JPEG `Data`) happens in the **ViewModel**, not in the view's save closure | Views do not encode or reshape data (main ADR §6) |

---

## 2. File Locations

| Thing | Location |
|---|---|
| `AppRoute` enum | `App/AppRoute.swift` |
| `AppCoordinator.path`, `showX()` intent methods | `App/AppCoordinator.swift` |
| `navigationDestination(for: AppRoute.self)` switch | `App/MainTabView.swift` |
| Shared ViewModel instance created for parent + destination | `App/MainTabView.swift` (`@State`) |
| List/filter state and derived values | `Modules/<Feature>/ViewModel/` |
| Intent closures (for example `onAddCattleTap`) | Declared by the module's View `init`, wired in `App/MainTabView.swift` |
| Pushed form view (for example `SapiFormView`) | The feature module that owns the form, `Modules/<Feature>/View/` |

---

## 3. Rules

1. `AppRoute` stays `Hashable` and carries **values only, never closures** (unlike `AppSheet`, which carries closures). Results flow back through completion closures composed in `MainTabView`.
2. A module never references a route or a destination view. It only exposes an intent closure and lets `App/*` map it to `coordinator.showX()`.
3. A ViewModel `init` stays cheap: storing dependencies only. Filter state starts empty/default; derived properties compute on access.
4. A view never calls `repository`, encodes data, or builds derived strings. If body needs it, it reads a ViewModel computed property.
5. One ViewModel instance per data domain per screen tree. Do not call `container.makeXViewModel()` twice for the same domain when both instances display the same data.
6. A pushed form receives its save closure through `init` (as `SapiFormView` does). The closure is composed in `MainTabView` and calls the shared ViewModel.
7. A completion side effect (refresh after save) belongs inside the ViewModel method (for example `add()` refreshes `items`), not as a second call chained from the view or `MainTabView`.

---

## 4. Implementation

### 4.1 `AppRoute`

```swift
enum AppRoute: Hashable {
    case profile
    case sapiDetail(id: String)
    case addCattle
}
```

### 4.2 `AppCoordinator`

```swift
func showAddCattle() {
    path.append(.addCattle)
}
```

### 4.3 `MainTabView`

```swift
struct MainTabView: View {
    let container: DIContainer
    @Bindable var coordinator: AppCoordinator
    @State private var cattlesViewModel: CattlesViewModel

    init(container: DIContainer, coordinator: AppCoordinator) {
        self.container = container
        _coordinator = Bindable(wrappedValue: coordinator)
        // One shared instance so the home list and the add-cattle form stay in sync.
        _cattlesViewModel = State(initialValue: container.makeCattlesViewModel())
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            HomeView(
                viewModel: container.makeHomeViewModel(),
                cattlesViewModel: cattlesViewModel,
                // ...
                onAddCattleTap: { coordinator.showAddCattle() }
            )
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .profile:
                    ProfileView(viewModel: container.makeProfileViewModel())
                case .sapiDetail(let id):
                    // No sync needed with the list: fresh instance is fine.
                    CattlesDetailView(cattleID: id, viewModel: container.makeCattlesViewModel())
                case .addCattle:
                    // Mutates list data: uses the shared instance.
                    SapiFormView { name, date, breed, gender, recordedAge, bodyWeight, cattleImage, notes in
                        try cattlesViewModel.addCattle(
                            name: name,
                            dateAcquired: date,
                            breed: breed,
                            gender: gender,
                            recordedAge: recordedAge,
                            bodyWeight: bodyWeight,
                            cattleImage: cattleImage,
                            notes: notes
                        )
                    }
                }
            }
        }
    }
}
```

### 4.4 ViewModel (list/filter state and derived values)

```swift
@Observable @MainActor
final class CattlesViewModel {
    var selectedBreeds: Set<String> = []
    var selectedGenders: Set<String> = []
    var selectedAgeRanges: Set<String> = []
    var sortAscending = false

    var filteredItems: [Cattle] { /* filter + sort over items */ }
    var hasNoVisibleCattle: Bool { items.isEmpty || filteredItems.isEmpty }
    var listSubtitle: String { /* reads filteredItems.count */ }

    func toggleSort() { sortAscending.toggle() }

    func addCattle(/* form fields, cattleImage: UIImage? */) throws {
        let imageData = cattleImage?.jpegData(compressionQuality: 0.85)
        try add(/* ..., cattleImage: imageData, ... */)  // add() refreshes items
    }
}
```

### 4.5 Caller side (module view)

```swift
// HomeView: pure presentation, no filter @State, no navigation @State.
AddCattleButton(onTap: onAddCattleTap)

// Filter sheet: presentation state is local; selections bind to the ViewModel.
.sheet(isPresented: $isFilterPresented) {
    NavigationStack {
        @Bindable var cattlesViewModel = cattlesViewModel
        CattlesFilterView(
            selectedBreed: $cattlesViewModel.selectedBreeds,
            selectedGender: $cattlesViewModel.selectedGenders,
            selectedAgeRange: $cattlesViewModel.selectedAgeRanges
        )
    }
}
```

### 4.6 Flow summary

```
User taps add -> HomeView onAddCattleTap closure
    -> AppCoordinator.showAddCattle() -> path.append(.addCattle)
    -> MainTabView navigationDestination(for:) builds SapiFormView with shared CattlesViewModel
    -> user saves -> save closure -> cattlesViewModel.addCattle(...)
    -> ViewModel encodes image, writes via repository, refreshes items
    -> @Observable state change updates the list behind the pushed screen
```

---

## 5. Previews

- Destination views (forms) preview with their save closure as a no-op: `SapiFormView { _, _, _, _, _, _, _, _ in }`.
- List views preview with a ViewModel built from `MockCattleRepository` and exercise the computed properties directly, no container.

---

## 6. Known Trade-offs

- `MainTabView` grows with every route. If it gets large, extract an `AppRouteView` builder (mirroring `AppSheetView`) or split the switch per tab.
- `AppRoute` is value-only, so it cannot carry result closures; results must flow through shared ViewModels or coordinator-held closures. Sheets (ADR 01) remain the tool when a closure-carrying payload is needed.
- The shared-instance rule relies on discipline (folders are not compiler-enforced). Violations show up as stale lists after saves — check instance sharing first when that symptom appears.
- `navigationDestination(for:)` is attached once per `NavigationStack`; a route pushed from another tab's stack needs its own stack decision.

---

## 7. Open Questions

- Should other tabs (History, Profile) get their own coordinator `path` arrays, or keep a single path while only the Home tab pushes routes?
- When should a one-off local screen (for example a transient confirmation) be allowed to use `.navigationDestination(isPresented:)` locally, mirroring ADR 01's "trivial sheet stays local" exception? Decide when the first case appears.
- Should `AppRoute` grow associated values for edit flows (`editCattle(id:)`), and does the shared-instance rule extend to edit destinations?
