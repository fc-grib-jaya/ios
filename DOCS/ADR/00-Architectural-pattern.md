# Architecture Decisions: Cattle Weight iOS App

> Purpose: context transfer. Paste this into a new conversation so the assistant follows the same structuring rules.
> Project: iOS app that estimates cattle weight from LiDAR mesh scanning plus formula-based computation.
> Tech: Swift, SwiftUI, ARKit (LiDAR), Vision, Core ML, SwiftData.
> Language rule: all code, comments, UI strings, and docs are written in English.

---

## 1. Core Decisions

| # | Decision | Rationale |
|---|---|---|
| 1 | **Modular by feature**, as folders inside a **single target** (no Swift Packages yet) | Simple to start; structure can later be lifted into local packages with little refactoring |
| 2 | Every module has `View/`, `ViewModel/`, `Model/` | Everything for one feature lives in one place |
| 3 | **MVVM with the Observation framework** (`@Observable`, `@State`), minimum iOS 26 | Less boilerplate than `ObservableObject`; Liquid Glass requires iOS 26 |
| 4 | **Protocols as contracts** between modules | Modules stay decoupled; LiDAR-dependent code can be mocked (no LiDAR in Simulator) |
| 5 | **`DIContainer`** builds and wires ViewModels | One place to see who uses which implementation |
| 6 | **`AppCoordinator`** owns navigation and app phase | Flow lives in one place; modules do not know the next screen |
| 7 | Shared UI lives in **`Core/UI`** (renamed from DesignSystem) | Consistent look; one place to change the design |

---

## 2. Directory Structure

```
App/
├── MainApp.swift            // @main entry point (named MainApp, not <Project>App)
├── AppCoordinator.swift
├── AppRoute.swift
├── DIContainer.swift
├── RootView.swift
└── MainTabView.swift

Modules/
└── <Feature>/
    ├── View/
    ├── ViewModel/
    ├── Model/
    └── Service/             // optional: feature-specific services and repositories

Core/
├── Contracts/               // cross-module protocols and shared models
├── Persistence/             // generic storage infrastructure
├── Extensions/
├── Utilities/
├── Mocks/                   // shared mocks for previews and tests
└── UI/
    ├── Components/
    ├── Tokens/              // AppColor, AppFont, AppSpacing, AppRadius
    └── Modifiers/

Resources/
```

Initial modules: Splash, Home, Profile, Scanning, History. Planned: Segmentation, Measurement, WeightEstimation.

---

## 3. Dependency Rules

1. `Modules/*` may use `Core/*`.
2. `Core/*` must **never** reference `Modules/*` or `App/*`.
3. A module must **never** reference another module directly.
4. Only `App/*` knows every module and concrete implementation. It wires them together.
5. Navigation between modules goes through **closures** (for example `onProfileTap`) supplied by `App/*`.
6. Because modules are plain folders, these rules are enforced by discipline and code review, not by the compiler. If violations become frequent, migrate to local Swift Packages.

---

## 4. Where Things Go

| Thing | Location | Rule |
|---|---|---|
| Protocol used by 2+ modules (for example `CattleRepository`, `MeshProviding`) | `Core/Contracts/` | Move here when a second module needs it |
| Protocol used by one module | That module's `Service/` or `Model/` | Start local, promote later |
| Model used by a Core protocol (for example `Cattle`) | `Core/Contracts/` | A Core protocol cannot reference a type that lives in `Modules` |
| Feature-only model | `Modules/<Feature>/Model/` | |
| Concrete implementation (for example `LiDARScanService`) | Its feature module's `Service/` | |
| Shared UI component | `Core/UI/Components/` | Used by 2+ modules, no domain knowledge, takes data via parameters |
| Feature-specific UI component | That module's `View/` | Contains domain logic or is bound to a ViewModel |
| Generic persistence infrastructure (ModelContainer setup, file store) | `Core/Persistence/` | Must not know feature models |
| Mock used across modules | `Core/Mocks/` | |
| Mock used by one module | That module, inside `#if DEBUG` | |
| Static reference data (for example nutrient tables) | `Modules/<Feature>/Defaults/`, or `Core/ReferenceData/` if shared | Typed Swift constants, not string-keyed dictionaries |

**`DIContainer` never defines contracts.** It only assembles concrete implementations behind protocols.

---

## 5. App Layer Rules

- **`MainApp`**: creates the container and coordinator, then shows `RootView`.
- **`AppCoordinator`**: `@Observable @MainActor`. Holds `phase` (`.splash` / `.main`) and `path: [AppRoute]`. Exposes intent methods such as `finishSplash()` and `showProfile()`.
- **`DIContainer`**:
  - Holds dependencies as protocols (`any CattleRepository`).
  - Constructor injection via `init`.
  - `static func live(...)` for real backends, `static func demo(...)` / `.preview` for previews.
  - Factory methods `makeXViewModel(...)` take navigation closures as parameters.
  - In `demo`, replace the **lowest layer** (for example the API client) so repository logic is still exercised.
  - Split into per-area assemblies if it grows too large.
- **`MainTabView`**: `NavigationStack(path:)` bound to `coordinator.path`. `navigationDestination` builds destination views lazily.
- **`@Bindable`** is used only when a view needs `$coordinator.path`. A plain `let` is enough when the view only reads properties or calls methods.
- **`@State`** is used where the view owns the object (for example in `MainApp`).

---

## 6. ViewModel and View Rules

1. Views **do not create their own ViewModels**. `DIContainer` creates them and passes them in through `init`.
2. A View stores its ViewModel with `@State` and receives it through `init`.
3. **`init` of a ViewModel must be cheap**: only store dependencies. No `ARSession`, Core ML loading, I/O, timers, or logging in `init`.
4. Heavy work goes in `.task { await viewModel.load() }` or explicit methods.
5. Reason: `body` can be re-evaluated often, and the factory call inside `body` runs each time. `@State` keeps only the first instance and the extra ones are discarded. `@autoclosure` does **not** prevent this for `@State`; it only helps with `@StateObject`.
6. ViewModels are `@Observable @MainActor`.
7. Every View has a `#Preview` that builds its ViewModel with mocks, without depending on the live container.

---

## 7. Persistence Rules

- `Core/Persistence` provides generic infrastructure only.
- Model types are **passed in from `App`**, so Core never imports feature models:

```swift
enum PersistenceController {
    static func makeContainer(
        for types: [any PersistentModel.Type],
        inMemory: Bool = false
    ) throws -> ModelContainer { ... }
}
```

- `@Model` classes stay in their feature module (or `Core/Contracts` if shared).
- Use `inMemory: true` for previews and tests.
- Data that is static in code needs **no cache layer**. A Swift `static let` is already initialized once. Only add version-based seeding if the data must be persisted, updated remotely, or edited by users.

---

## 8. Mocking and Previews

- Mock repositories keep data in memory (arrays) and conform to the same protocol.
- Provide `DIContainer.preview` (or `.demo`) so previews need no backend or LiDAR:

```swift
#Preview {
    MainTabView(container: .preview, coordinator: AppCoordinator())
}
```

- Prefer replacing the lowest layer (API client, mesh provider) over replacing whole repositories, when practical.

---

## 9. Design System (`Core/UI`)

- Tokens are caseless `enum` namespaces: `AppColor`, `AppFont`, `AppSpacing`, `AppRadius`.
- No hardcoded colors or numbers in views; use tokens. Use semantic system colors so dark mode works.
- First component: `GlassPrimaryButton`, a red Liquid Glass capsule using `glassEffect` (iOS 26).

---

## 10. Known Trade-offs

- More files and boilerplate up front.
- Module boundaries are not compiler-enforced.
- `DIContainer` can grow large and may need splitting.
- Risk of over-engineering: not every feature needs its own protocol and service.
- `Core/Persistence` is a placeholder until a second persistence consumer exists. It can be removed and recreated later.

---

## 11. Open Questions

- Will scan meshes be stored locally only, or synced to a server? (affects `Core/Persistence`)
- How does mesh data flow from Scanning to Measurement: **pull** (shared service with `latestMesh()`) or **push** (callback through the coordinator)? Pull is simpler; push makes the flow explicit.
- Should formulas (Schaeffer, Winter, volume-based) be selectable by the user or fixed?
- Will the nutrient reference data stay static, or become remotely updatable or user-editable?
