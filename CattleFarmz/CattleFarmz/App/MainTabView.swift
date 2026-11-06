//
//  MainTabView.swift
//  CattleFarmz
//

import SwiftUI

/// Main tab interface: Home, Scan, and History.
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
                    },
                    onCardTap: { cattleID in
                        coordinator.goToSapiDetail(id: cattleID)
                    }
                )
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .profile:
                        ProfileView(viewModel: container.makeProfileViewModel())
                    case .sapiDetail(let id):
                        CattlesDetailView(
                            cattleID: id,
                            viewModel: container.makeCattlesViewModel()
                        )
                    }
                }
            }
            .tabItem {
                Label("Beranda", systemImage: "house")
            }

//            ScanningView()
//                .tabItem {
//                    Label("Bobot", systemImage: "powermeter")
//                }

            HistoryView()
                .tabItem {
                    Label("Pakan", systemImage: "carrot")
                }

//            ProfileView(viewModel: container.makeProfileViewModel())
//                .tabItem {
//                    Label("Profil", systemImage: "person")
//                }
        }
        .tint(AppColor.primary)
        .sheet(item: $coordinator.sheet) { sheet in
            switch sheet {
            case .examplePickerSheet(let current, let onSelect):
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
