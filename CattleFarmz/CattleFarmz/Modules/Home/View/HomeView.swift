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
    private let onProfileTap: () -> Void

    init(viewModel: HomeViewModel, onProfileTap: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onProfileTap = onProfileTap
    }

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            Text(viewModel.placeholder)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
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
        HomeView(viewModel: HomeViewModel(), onProfileTap: {})
    }
}
