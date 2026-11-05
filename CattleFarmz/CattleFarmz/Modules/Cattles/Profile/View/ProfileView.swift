//
//  ProfileView.swift
//  CattleFarmz
//

import SwiftUI

/// Profile screen with an avatar, name, and email.
struct ProfileView: View {
    @State private var viewModel: ProfileViewModel

    /// Side length of the avatar image.
    private static let avatarSize: CGFloat = 120

    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.medium) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Self.avatarSize, height: Self.avatarSize)
                    .foregroundStyle(AppColor.primary)

                Text(viewModel.profile.name)
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.textPrimary)

                Text(viewModel.profile.email)
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .padding(AppSpacing.large)
        }
        .navigationTitle("Profile")
    }
}

#Preview {
    NavigationStack {
        ProfileView(viewModel: ProfileViewModel())
    }
}
