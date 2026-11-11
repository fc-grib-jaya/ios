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
    case rationForm
    case rationAnalysis
    case rationAnalysisDetail
}

enum AppSheet: Identifiable {
    case examplePickerSheet(current: String, onSelect: ([String]) -> Void )
    
    var id: String {
        switch self {
        case .examplePickerSheet: "examplePicker"
        }
    }
}
