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

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            if cattlesViewModel.items.isEmpty {
                ScrollView(.vertical, showsIndicators: false) {
                    NoCattleCard(tambahSapi: $tambahSapi)
                        .padding()
                }
            } else {
                VStack {
                    AddCattleButton(tambahSapi: $tambahSapi)
                    CattlesView(viewModel: cattlesViewModel, onCardTap: onCardTap)
                }
            }
        }
        .task { await cattlesViewModel.load() }
        .navigationTitle(viewModel.title)
        .toolbar {
            ToolbarItem(
                placement: .topBarLeading,
                content: {
                    Menu {
                        Button("Opsi 1", systemImage: "star") {}
                        Button("Opsi 2", systemImage: "gear") {}
                        Divider()
                        Button("Hapus", systemImage: "trash", role: .destructive) {}
                    } label: {
                        Label("Menu", systemImage: "line.3.horizontal.decrease")
                    }
                }
            )
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.startScan()
                    onProfileTap()
                } label: {
                    Image(systemName: "camera.fill")
                }
                .accessibilityLabel("Profile")
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    tambahSapi = true
                } label: {
                    Label("Menu", systemImage: "line.3.horizontal.decrease")
                }
                .accessibilityLabel("Pick Example")
            }
        }
        .sheet(isPresented: $tambahSapi) {
            NavigationStack {
                SapiFormView { name, date, breed, gender, recordedAge, bodyWeight, cattleImage, notes in
                    try cattlesViewModel.add(
                        name: name,
                        dateAcquired: date,
                        breed: breed,
                        gender: gender,
                        recordedAge: recordedAge,
                        chestGirth: nil,
                        bodyLength: nil,
                        bodyWeight: bodyWeight,
                        cattleImage: cattleImage?.jpegData(compressionQuality: 0.85),
                        notes: notes
                    )

                    await cattlesViewModel.load()
                }
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
