//
//  MainApp.swift
//  CattleFarmz
//

import SwiftUI

/// Application entry point and the only `@main` type in the target.
///
/// It owns the single dependency container and the app coordinator, and hands
/// both to `RootView`, which decides which screen is visible.
@main
struct MainApp: App {
    @State private var container = DIContainer()
    @State private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            RootView(container: container, coordinator: coordinator)
        }
    }
}
