//
//  AppCoordinator.swift
//  CattleFarmz
//

import Observation

/// The two top-level states the app can be in.
enum AppPhase {
    /// Startup screen shown before the main interface.
    case splash
    /// Main tab interface.
    case main
}

/// Owns app-level state: the visible phase and the navigation path of the Home tab.
///
/// Modules never create routes themselves. They request navigation through the
/// closures that this coordinator's methods are wired into by the `App` layer.
@Observable
@MainActor
final class AppCoordinator {
    /// Current top-level app phase.
    var phase: AppPhase = .splash


    /// Leaves the splash screen and reveals the main tab interface.
    func finishSplash() {
        phase = .main
    }

    
    /// Navigation path of the Home tab, expressed as `AppRoute` values.
    var path: [AppRoute] = []
    
    /// Pushes the profile screen onto the Home navigation stack.
    func showProfile() {
        path.append(.profile)
    }
    
    func goToSapiDetail(id: String) {
        path.append(.sapiDetail(id: id))
    }
}
