//
//  MainTabView.swift
//  CattleFarmz
//

import SwiftUI

/// Main tab interface: Home, Scan, and History.
///
/// Only this view knows which module backs each tab, and it is the place where
/// module navigation closures are wired to the coordinator.
struct MainTabView: View {
    let container: DIContainer
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        TabView {
            NavigationStack(path: $coordinator.path) {
                HomeView(
                    viewModel: container.makeHomeViewModel(),
                    cattlesViewModel: container.makeCattlesViewModel(),
                    onProfileTap: { coordinator.showProfile() }
                )
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .profile:
                        ProfileView(viewModel: container.makeProfileViewModel())
                    case .sapiDetail(id: "idSapi1"):
                        EmptyView()
                        
                    default: EmptyView()
                    }
                }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            ScanningView()
                .tabItem {
                    Label("Scan", systemImage: "viewfinder")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }
        }
    }
}

#Preview {
    MainTabView(container: DIContainer.preview, coordinator: AppCoordinator())
}
