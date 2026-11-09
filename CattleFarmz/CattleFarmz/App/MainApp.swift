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
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var coordinator = AppCoordinator()

    // Model types come from modules; only the App layer may know them.
    let modelContainer: ModelContainer
    let container: DIContainer

    init() {
        do {
            let mc = try PersistenceController.makeContainer(
                for: [
                    Cattle.self,
                    StoredFeedIngredient.self,
                    FeedCatalogSeedState.self
                ]
            )
            modelContainer = mc
            container = DIContainer.live(modelContext: mc.mainContext)
            
            UISegmentedControl.appearance().selectedSegmentTintColor =
                UIColor(AppColor.Primitive.Primary.shade500)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(container: container, coordinator: coordinator)
                .modelContainer(modelContainer)
                .task { container.haptics.prepare() }
        }
    }
}
