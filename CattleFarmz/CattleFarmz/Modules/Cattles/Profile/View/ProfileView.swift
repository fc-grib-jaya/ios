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
            AppColor.Surface.canvas
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.md) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Self.avatarSize, height: Self.avatarSize)
                    .foregroundStyle(AppColor.Button.Primary.background)

                Text(viewModel.profile.name)
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.Text.primary)

                Text(viewModel.profile.email)
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.Text.secondary)
            }
            .padding(AppSpacing.xl)
        }
        .navigationTitle("Profile")
    }
}

#Preview {
    NavigationStack {
        ProfileView(viewModel: ProfileViewModel())
    }
}
