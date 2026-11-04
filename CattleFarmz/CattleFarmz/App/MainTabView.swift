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
                    onProfileTap: { coordinator.showProfile() },
                    onExamplePickerTap: {
                        coordinator.showExamplePickerSheet(
                            current: "Sapi 1",
                            onSelect: { selected in
                                print("Example picker selected: \(selected)")
                                coordinator.dismissSheet()
                            }
                        )
                    }
                )
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .profile:
                        ProfileView(viewModel: container.makeProfileViewModel())

                    default: EmptyView()
                    }
                }
            }
            .tabItem {
                Label("Beranda", systemImage: "house")
            }

            ScanningView()
                .tabItem {
                    Label("Bobot", systemImage: "powermeter")
                }

            HistoryView()
                .tabItem {
                    Label("Pakan", systemImage: "carrot")
                }
            
            ScanningView()
                .tabItem {
                    Label("Profil", systemImage: "person")
                }
        }
        .sheet(item: $coordinator.sheet) { sheet in
            switch sheet {
            case .examplePickerSheet(current: let current, onSelect: let onSelect):
                ExamplePickerSheetView(
                    viewModel: container.makeExamplePickerSheetViewModel(
                        current: current,
                        onSelect: onSelect
                    )
                )
            }
        }
    }
}

#Preview {
    MainTabView(container: DIContainer.preview, coordinator: AppCoordinator())
}
