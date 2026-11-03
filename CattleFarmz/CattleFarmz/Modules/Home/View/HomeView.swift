//
//  HomeView.swift
//  CattleFarmz
//

import SwiftUI

/// Home screen placeholder with an entry point to the profile page.
///
/// The view never references the profile screen; it asks the `App` layer to
/// navigate by calling `onProfileTap`.
struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var cattlesViewModel: CattlesViewModel
    private let onProfileTap: () -> Void

    init(viewModel: HomeViewModel, cattlesViewModel: CattlesViewModel, onProfileTap: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        _cattlesViewModel = State(initialValue: cattlesViewModel)
        self.onProfileTap = onProfileTap
    }

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            CattlesView(viewModel: cattlesViewModel)
        }
        .navigationTitle(viewModel.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onProfileTap) {
                    Image(systemName: "person.crop.circle")
                }
                .accessibilityLabel("Profile")
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView(
            viewModel: HomeViewModel(),
            cattlesViewModel: CattlesViewModel(repository: MockCattleRepository(), calculation: WeightCalculator()),
            onProfileTap: {}
        )
    }
}
