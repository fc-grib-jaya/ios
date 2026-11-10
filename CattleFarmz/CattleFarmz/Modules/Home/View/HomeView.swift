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
    private let onScanTap: () -> Void
    private let onCardTap: (String) -> Void
    private let onAddCattleTap: () -> Void
    private let onToastTap: () -> Void

    init(
        viewModel: HomeViewModel,
        cattlesViewModel: CattlesViewModel,
        onProfileTap: @escaping () -> Void,
        onExamplePickerTap: @escaping () -> Void,
        onScanTap: @escaping () -> Void,
        onCardTap: @escaping (String) -> Void,
        onAddCattleTap: @escaping () -> Void,
        onToastTap: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        _cattlesViewModel = State(initialValue: cattlesViewModel)
        self.onProfileTap = onProfileTap
        self.onExamplePickerTap = onExamplePickerTap
        self.onScanTap = onScanTap
        self.onCardTap = onCardTap
        self.onAddCattleTap = onAddCattleTap
        self.onToastTap = onToastTap
    }

    @State private var isFilterPresented = false

    var body: some View {
        ZStack {
            AppColor.Surface.canvas
                .ignoresSafeArea()
            VStack(alignment: .leading) {
                Text("Halo, Bapak Tono!")
                    .font(AppFont.largeTitle)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.md)
                    .padding(.bottom, AppSpacing.sm)

                Text(cattlesViewModel.listSubtitle)
                    .font(AppFont.body)
                    .padding(.horizontal, AppSpacing.md)

                Button("Show toast", action: onToastTap)
                    .appButtonStyle(.secondary)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.xs)

                ScrollView(.vertical, showsIndicators: false) {
                    if cattlesViewModel.hasNoVisibleCattle {
                        NoCattleCard(onAddTap: onAddCattleTap)
                            .padding()
                        Spacer()
                    } else {
                        AddCattleButton(onTap: onAddCattleTap)
                            .padding(.vertical, AppSpacing.xs)
                        CattlesView(
                            viewModel: cattlesViewModel,
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
                    cattlesViewModel.toggleSort()
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .scaleEffect(y: cattlesViewModel.sortAscending ? 1 : -1)
                }
                .accessibilityLabel(
                    cattlesViewModel.sortAscending
                        ? "Urutkan tanggal terbaru ke terlama"
                        : "Urutkan tanggal terlama ke terbaru"
                )
            }

            ToolbarSpacer(.fixed, placement: .topBarTrailing)

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isFilterPresented = true
                } label: {
                    Label("Menu", systemImage: "line.3.horizontal.decrease")
                }
                .accessibilityLabel("Filter sapi")
            }
        }
        .sheet(isPresented: $isFilterPresented) {
            NavigationStack {
                @Bindable var cattlesViewModel = cattlesViewModel
                CattlesFilterView(
                    selectedBreed: $cattlesViewModel.selectedBreeds,
                    selectedGender: $cattlesViewModel.selectedGenders,
                    selectedAgeRange: $cattlesViewModel.selectedAgeRanges
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var toastManager = ToastManager()

    NavigationStack {
        HomeView(
            viewModel: HomeViewModel(haptics: NoopHaptics()),
            cattlesViewModel: CattlesViewModel(
                repository: MockCattleRepository(),
                calculation: WeightCalculator()
            ),
            onProfileTap: {},
            onExamplePickerTap: {},
            onScanTap: {},
            onCardTap: { _ in },
            onAddCattleTap: {},
            onToastTap: { toastManager.show("Your changes have been saved") }
        )
        .toast(manager: toastManager)
    }
}
