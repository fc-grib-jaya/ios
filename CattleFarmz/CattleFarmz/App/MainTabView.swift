//
//  MainTabView.swift
//  CattleFarmz
//

import SwiftUI

/// Main tab interface: Home, Scan, and History.
struct MainTabView: View {
    let container: DIContainer
    @Bindable var coordinator: AppCoordinator
    @State private var cattlesViewModel: CattlesViewModel

    init(container: DIContainer, coordinator: AppCoordinator) {
        print("Homeview init")
        self.container = container
        _coordinator = Bindable(wrappedValue: coordinator)
        // One shared instance so the home list and the add-cattle form stay in sync.
        _cattlesViewModel = State(
            initialValue: container.makeCattlesViewModel()
        )
    }

    var body: some View {
        TabView {
            NavigationStack(path: $coordinator.path) {
                HomeView(
                    viewModel: container.makeHomeViewModel(),
                    cattlesViewModel: cattlesViewModel,
                    farmerName: container.farmerName(),
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
                        coordinator.goToCattleDetail(cattleID: cattleID)
                    },
                    onAddCattleTap: {
                       print("on add cattle tap")
                        coordinator.showAddCattle() }
                )
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .profile:
                        ProfileView(viewModel: container.makeProfileViewModel())
                    case .cattleDetail(let id):
                        // Shares the list instance: editing from the detail
                        // screen mutates the same data the home list shows.
                        CattlesDetailView(
                            cattleID: id,
                            viewModel: cattlesViewModel,
                            onEditTap: coordinator.showEditCattleSheet,
                        )
                    case .addCattle:
                        CattleFormView(
                            onScanSession: { onFinish in
                                coordinator.showScanSession(onFinish: onFinish)
                            },
                            viewModel: container.makeCattleFormViewModel()
                        ) { name, date, breed, gender, recordedAge, bodyWeight, cattleImage, notes in
                            try cattlesViewModel.addCattle(
                                name: name,
                                dateAcquired: date,
                                breed: breed,
                                gender: gender,
                                recordedAge: recordedAge,
                                bodyWeight: bodyWeight,
                                cattleImage: cattleImage,
                                notes: notes
                            )
                        }
                    }
                }
            }
            .tabItem {
                Label("Beranda", systemImage: "house")
            }

            RationPlanningView(
                viewModel: container.makeRationPlanningViewModel()
            )
            .tabItem {
                Label("Pakan", systemImage: "leaf")
            }
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "carrot")
                }

            ProfileView(viewModel: container.makeProfileViewModel())
                .tabItem {
                    Label("Profil", systemImage: "person")
                }
        }
        .toast(manager: container.toastManager)
        .sheet(item: $coordinator.sheet) { sheet in
            switch sheet {
            case .examplePickerSheet(let current, let onSelect):
                ExamplePickerSheetView(
                    viewModel: container.makeExamplePickerSheetViewModel(
                        current: current,
                        onSelect: onSelect
                    )
                )
            case .editCattle(let cattle, let onSave):
                NavigationStack {
                    CattlesEditForm(cattle: cattle, onSave: onSave)
                }
            case .guestLoginSheet(let onDone):
                GuestLoginSheetView(
                    viewModel: container.makeGuestLoginSheetViewModel(onDone: onDone)
                )
            }
        }
        .fullScreenCover(item: $coordinator.cover) { cover in
            AppCoverView(cover: cover, container: container)
        }
        .alert(
            "LiDAR Tidak Tersedia",
            isPresented: Binding(
                get: { coordinator.scanErrorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        coordinator.scanErrorMessage = nil
                    }
                }
            )
        ) {
            Button("Kembali", role: .cancel) {}
        } message: {
            Text(coordinator.scanErrorMessage ?? "Perangkat ini tidak mendukung pemindaian LiDAR.")
        }
    }
}

#Preview {
    MainTabView(container: DIContainer.preview, coordinator: AppCoordinator())
}
