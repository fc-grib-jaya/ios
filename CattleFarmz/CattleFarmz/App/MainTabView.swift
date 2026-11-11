//
//  MainTabView.swift
//  CattleFarmz
//

import SwiftUI
import SwiftData

/// Main tab interface: Home, Scan, and History.
struct MainTabView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Cattle.name) private var cattle: [Cattle]
    @State private var selectedCattle: Cattle?
    @State private var saveError: String?
    let container: DIContainer
    @Bindable var coordinator: AppCoordinator
    @State private var cattlesViewModel: CattlesViewModel
    @State private var rationViewModel: RationPlanningViewModel
    @State private var analysisResult: RationCalculationResult?

    init(container: DIContainer, coordinator: AppCoordinator) {
        print("Homeview init")
        self.container = container
        _coordinator = Bindable(wrappedValue: coordinator)
        // One shared instance so the home list and the add-cattle form stay in sync.
        _cattlesViewModel = State(initialValue: container.makeCattlesViewModel())
        _rationViewModel = State(initialValue: container.makeRationPlanningViewModel())
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
                            onEditTap: { cattle in
                                coordinator.showEditCattle(cattleID: cattle.id.uuidString)
                            }
                        )
                    case .rationForm: rationForm
                    case .rationAnalysis:
                        rationAnalysisDestination
                    case .rationAnalysisDetail:
                        rationAnalysisDetailDestination
                    case .addCattle:
                        CattleFormView(
                            onScanSession: { onFinish in
                                coordinator.showScanSession(onFinish: onFinish)
                            },
                            viewModel: container.makeCattleFormViewModel()
                        ) { values in
                            try cattlesViewModel.addCattle(
                                name: values.name,
                                dateAcquired: values.dateAcquired,
                                breed: values.breed,
                                gender: values.gender,
                                recordedAge: values.recordedAge,
                                bodyWeight: values.bodyWeight,
                                cattleImage: values.cattleImage,
                                notes: values.notes
                            )
                        }
                    case .editCattle(let id):
                        if let cattle = cattlesViewModel.items.first(
                            where: { $0.id.uuidString == id }
                        ) {
                            CattleFormView(
                                cattle: cattle,
                                onScanSession: { onFinish in
                                    coordinator.showScanSession(onFinish: onFinish)
                                },
                                viewModel: container.makeCattleFormViewModel()
                            ) { values in
                                if let error = cattlesViewModel.editCattle(
                                    values,
                                    for: cattle
                                ) {
                                    throw NSError(
                                        domain: "CattleForm",
                                        code: 1,
                                        userInfo: [NSLocalizedDescriptionKey: error]
                                    )
                                }
                            }
                        } else {
                            ContentUnavailableView(
                                "Sapi Tidak Ditemukan",
                                systemImage: "exclamationmark.triangle"
                            )
                        }
                    }
                }
            }
            .tabItem {
                Label("Beranda", systemImage: "house")
            }
            
            NavigationStack(path: $coordinator.rationPath) {
                FeedHomeView(entries: cattle.map { cow in
                    FeedHomeEntry(id: cow.id, name: cow.name, details: cattleDetails(cow),
                                  photo: cow.cattleImage, updated: cow.rationUpdatedAt, adg: cow.rationTargetADG)
                }, onOpen: openPlan)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .rationForm: rationForm
                    case .rationAnalysis: rationAnalysisDestination
                    case .rationAnalysisDetail: rationAnalysisDetailDestination
                    default: EmptyView()
                    }
                }
            }
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
        .alert("Pakan", isPresented: Binding(get: { saveError != nil }, set: { if !$0 { saveError = nil } })) {
            Button("Tutup") { saveError = nil }
        } message: { Text(saveError ?? "") }
        .sheet(item: $coordinator.sheet) { sheet in
            switch sheet {
            case .examplePickerSheet(let current, let onSelect):
                ExamplePickerSheetView(
                    viewModel: container.makeExamplePickerSheetViewModel(
                        current: current,
                        onSelect: onSelect
                    )
                )
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

    private func cattleDetails(_ cow: Cattle) -> String {
        "\(cow.breed.rawValue) · \(cow.gender.rawValue) · \(cow.currentAge) bulan"
    }

    private func openPlan(_ id: UUID) {
        guard let cow = cattle.first(where: { $0.id == id }) else { return }
        let vm = container.makeRationPlanningViewModel()
        if let data = cow.savedRation {
            do {
                vm.restore(try JSONDecoder().decode(RationCalculationResult.self, from: data))
            } catch {
                saveError = "Susunan tersimpan gagal dibaca. " + error.localizedDescription
                return
            }
        } else {
            vm.selectSex(cow.gender == .male ? .male : .female)
            vm.selectStage(cow.currentAge < 6 ? .calf : cow.currentAge <= 12 ? .growing : .adult)
            vm.bodyWeightText = (cow.bodyWeight ?? cattlesViewModel.cattleWeight(for: cow)).map { String($0) } ?? ""
        }
        selectedCattle = cow
        rationViewModel = vm
        analysisResult = nil
        coordinator.rationPath.append(.rationForm)
    }

    @ViewBuilder
    private var rationForm: some View {
        if let cow = selectedCattle {
            RationPlanningView(rationVM: rationViewModel, cattleName: cow.name, cattleDetails: cattleDetails(cow)) { result in
                analysisResult = result
                coordinator.goToRationAnalysis()
            }
        }
    }

    private func savePlan(_ result: RationCalculationResult) {
        guard let cow = selectedCattle else { return }
        let previous = (cow.savedRation, cow.rationUpdatedAt, cow.rationTargetADG)
        do {
            cow.savedRation = try JSONEncoder().encode(result)
            cow.rationUpdatedAt = .now
            cow.rationTargetADG = result.profile.targetDailyWeightGainKilograms
            try context.save()
            coordinator.rationPath.removeAll()
        } catch {
            (cow.savedRation, cow.rationUpdatedAt, cow.rationTargetADG) = previous
            saveError = "Pakan gagal disimpan. " + error.localizedDescription
        }
    }

    @ViewBuilder
    private var rationAnalysisDetailDestination: some View {
        if let result = analysisResult {
            DetailAnalysisView(result: result, cattleName: selectedCattle?.name)
        } else {
            ContentUnavailableView("Belum ada hasil", systemImage: "chart.bar")
        }
    }

    @ViewBuilder
    private var rationAnalysisDestination: some View {
        if let result = analysisResult {
            RationAnalysisView(result: result, onShowDetails: coordinator.goToRationAnalysisDetail, cattleName: selectedCattle?.name, onSave: { savePlan(result) })
        } else {
            ContentUnavailableView(
                "Belum ada hasil",
                systemImage: "chart.bar",
                description: Text("Hitung nutrisi pakan terlebih dahulu.")
            )
        }
    }
}

#Preview {
    MainTabView(container: DIContainer.preview, coordinator: AppCoordinator())
}
