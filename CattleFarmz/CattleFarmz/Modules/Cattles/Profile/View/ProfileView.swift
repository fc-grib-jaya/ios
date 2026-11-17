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
    /// Presentation state of the about sheet; a trivial static sheet stays
    /// local (ADR 01).
    @State private var isAboutPresented = false

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

                if !viewModel.farmName.isEmpty {
                    Text(viewModel.farmName)
                        .font(AppFont.mediumSubheadline)
                        .foregroundStyle(AppColor.Text.secondary)
                }

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

                // About action as a neutral glass capsule.
                Button {
                    isAboutPresented = true
                } label: {
                    Label("Tentang", systemImage: "info.circle")
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
        .sheet(isPresented: $isAboutPresented) {
            AboutSheetView()
        }
        .task { viewModel.load() }
    }
}

/// Static about sheet with placeholder copy, shown at medium detent.
private struct AboutSheetView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(
                    """
                    Lorem ipsum dolor sit amet, consectetur adipiscing elit. \
                    Sed do eiusmod tempor incididunt ut labore et dolore magna \
                    aliqua. Ut enim ad minim veniam, quis nostrud exercitation \
                    ullamco laboris nisi ut aliquip ex ea commodo consequat. \
                    Duis aute irure dolor in reprehenderit in voluptate velit \
                    esse cillum dolore eu fugiat nulla pariatur. Excepteur sint \
                    occaecat cupidatat non proident, sunt in culpa qui officia \
                    deserunt mollit anim id est laborum.
                    """
                )
                .font(AppFont.body)
                .foregroundStyle(AppColor.Text.secondary)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.vertical, AppSpacing.md)
            }
            .navigationTitle("Tentang")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
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
