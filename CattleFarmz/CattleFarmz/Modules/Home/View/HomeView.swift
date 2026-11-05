//
//  HomeView.swift
//  CattleFarmz
//

import SwiftUI

/// Home screen with an entry point to the profile page and cattle detail pages.
struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var cattlesViewModel: CattlesViewModel
    private let onProfileTap: () -> Void
    private let onExamplePickerTap: () -> Void
    private let onCardTap: (String) -> Void

    init(
        viewModel: HomeViewModel,
        cattlesViewModel: CattlesViewModel,
        onProfileTap: @escaping () -> Void,
        onExamplePickerTap: @escaping () -> Void,
        onCardTap: @escaping (String) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        _cattlesViewModel = State(initialValue: cattlesViewModel)
        self.onProfileTap = onProfileTap
        self.onExamplePickerTap = onExamplePickerTap
        self.onCardTap = onCardTap
    }

    @State var tambahSapi: Bool = false
    @State var filterSapi: Bool = false

    @State private var selectedBreed: Set<String> = []
    @State private var selectedGender: Set<String> = []
    @State private var selectedAgeRange: Set<String> = []
    @State private var sortAscending = false

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()
            VStack(alignment: .leading) {
                Text("Halo, Bapak Tono!")
                    .font(AppFont.largeTitle)
                    .padding(.horizontal, AppSpacing.medium)
                    .padding(.top, AppSpacing.medium)
                    .padding(.bottom, AppSpacing.small)
                let filteredCattles = cattlesViewModel.filteredItems(
                    selectedBreed: selectedBreed,
                    selectedGender: selectedGender,
                    selectedAgeRange: selectedAgeRange,
                    sortAscending: sortAscending
                )

                Text(
                    cattlesViewModel.items.isEmpty || filteredCattles.count == 0
                        ? "Kamu belum menambahkan sapi. Tambahkan untuk hitung bobot dan rancangan pakan."
                        : "Kamu memiliki \(filteredCattles.count) sapi terdaftar."
                )
                .font(AppFont.body)
                .padding(.horizontal, AppSpacing.medium)
                
                ScrollView(.vertical, showsIndicators: false) {
                    if cattlesViewModel.items.isEmpty || filteredCattles.count == 0 {
                        NoCattleCard(tambahSapi: $tambahSapi)
                            .padding()
                        Spacer()
                    } else {
                        AddCattleButton(tambahSapi: $tambahSapi)
                            .padding(.vertical, AppSpacing.xm)
                        CattlesView(
                            viewModel: cattlesViewModel,
                            selectedBreed: selectedBreed,
                            selectedGender: selectedGender,
                            selectedAgeRange: selectedAgeRange,
                            sortAscending: sortAscending,
                            onCardTap: onCardTap
                        )
                    }
                }
            }
        }
        .task { await cattlesViewModel.load() }
        .navigationTitle(viewModel.title)
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    sortAscending.toggle()
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .scaleEffect(y: sortAscending ? 1 : -1)
                }
                .accessibilityLabel(
                    sortAscending
                        ? "Urutkan tanggal terbaru ke terlama"
                        : "Urutkan tanggal terlama ke terbaru"
                )
            }

            ToolbarSpacer(.fixed, placement: .topBarTrailing)

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    filterSapi = true
                } label: {
                    Label("Menu", systemImage: "line.3.horizontal.decrease")
                }
                .accessibilityLabel("Filter sapi")
            }
        }
        .navigationDestination(isPresented: $tambahSapi) {
            SapiFormView {
                name,
                date,
                breed,
                gender,
                recordedAge,
                bodyWeight,
                cattleImage,
                notes in
                try cattlesViewModel.add(
                    name: name,
                    dateAcquired: date,
                    breed: breed,
                    gender: gender,
                    recordedAge: recordedAge,
                    chestGirth: nil,
                    bodyLength: nil,
                    bodyWeight: bodyWeight,
                    cattleImage: cattleImage?.jpegData(
                        compressionQuality: 0.85
                    ),
                    notes: notes
                )

                await cattlesViewModel.load()
            }
        }
        .sheet(isPresented: $filterSapi) {
            NavigationStack {
                CattlesFilterView(
                    selectedBreed: $selectedBreed,
                    selectedGender: $selectedGender,
                    selectedAgeRange: $selectedAgeRange
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView(
            viewModel: HomeViewModel(haptics: NoopHaptics()),
            cattlesViewModel: CattlesViewModel(
                repository: MockCattleRepository(),
                calculation: WeightCalculator()
            ),
            onProfileTap: {},
            onExamplePickerTap: {},
            onCardTap: { _ in }
        )
    }
}
