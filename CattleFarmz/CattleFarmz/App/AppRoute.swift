//
//  AppRoute.swift
//  CattleFarmz
//

/// Destinations that can be pushed onto the Home navigation stack.
///
/// The `App` layer maps each route to a concrete screen, so modules stay
/// unaware of one another.
enum AppRoute: Hashable {
    /// Profile screen.
    case profile
    case cattleDetail(id: String)
    /// Add-cattle form screen.
    case addCattle
}

enum AppSheet: Identifiable {
    case examplePickerSheet(current: String, onSelect: ([String]) -> Void)
    case guestLoginSheet(onDone: () -> Void)
    /// Edit form for an existing cattle. `onSave` returns an error message
    /// on failure, or `nil` on success (the form stays open to show it).
    case editCattle(cattle: Cattle, onSave: (CattleEditValues) -> String?)

    var id: String {
        switch self {
        case .examplePickerSheet: "examplePicker"
        case .guestLoginSheet: "guestLogin"
        case .editCattle: "editCattle"
        }
    }
}
