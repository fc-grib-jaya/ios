//
//  MainApp.swift
//  CattleFarmz
//

import SwiftUI
import SwiftData

/// Application entry point and the only `@main` type in the target.
///
/// It owns the single dependency container and the app coordinator, and hands
/// both to `RootView`, which decides which screen is visible.
@main
struct MainApp: App {
    @State private var coordinator = AppCoordinator()

    // Model types come from modules; only the App layer may know them.
    let modelContainer: ModelContainer
    let container: DIContainer

    init() {
        do {
            let mc = try PersistenceController.makeContainer(for: [Cattle.self])
            modelContainer = mc
            container = DIContainer.live(modelContext: mc.mainContext)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(container: container, coordinator: coordinator)
                .modelContainer(modelContainer)
        }
    }
}
