//
//  ProfileView.swift
//  CattleFarmz
//

import SwiftUI

/// Profile screen: avatar and name near the top with the edit action right
/// below them, all center-aligned.
struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    private let onEditTap: () -> Void

    /// Side length of the avatar image.
    private static let avatarSize: CGFloat = 120

    init(
        viewModel: ProfileViewModel,
        onEditTap: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onEditTap = onEditTap
    }

    var body: some View {
        ZStack(alignment: .top) {
            AppColor.Surface.canvas
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.md) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Self.avatarSize, height: Self.avatarSize)
                    .foregroundStyle(AppColor.Button.Primary.background)

                Text(viewModel.name)
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.Text.primary)

                // Edit action as a neutral glass capsule.
                Button {
                    onEditTap()
                } label: {
                    Label("Ubah Profil", systemImage: "pencil")
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.Text.primary)
                        .padding(.horizontal, AppSpacing.xl)
                        .padding(.vertical, AppSpacing.md)
                }
                .glassEffect(.regular.interactive(), in: .capsule)
                .buttonStyle(.plain)
            }
            .padding(AppSpacing.xl)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProfileView(
            viewModel: ProfileViewModel(
                repository: MockUserProfileRepository(
                    profile: UserProfileConfiguration(name: "Tono")
                )
            ),
            onEditTap: {}
        )
    }
}
