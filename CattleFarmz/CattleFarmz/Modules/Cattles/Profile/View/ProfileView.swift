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

/// Static about sheet with the app credits, shown at medium detent.
private struct AboutSheetView: View {
    /// Everyone who built the app, in credit order.
    private static let developers = [
        "DF Bomanarakasura",
        "Ahmad Yasri Zaenuri",
        "Yuan Dimianta",
        "Salman Alfarizi Ramadhan",
        "Fajari Bagas",
        "Dylan Amadeus"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("CattleFarmz")
                            .font(AppFont.title)
                            .foregroundStyle(AppColor.Text.primary)
                        Text(
                            "Aplikasi pemantauan pertumbuhan dan perencanaan "
                                + "ransum sapi berbasis pengukuran morfometri."
                        )
                        .font(AppFont.mediumSubheadline)
                        .foregroundStyle(AppColor.Text.secondary)
                    }

                    Divider()

                    creditSection(
                        title: "Tim Pengembang",
                        entries: Self.developers.map { CreditEntry(name: $0) }
                    )

                    Divider()

                    creditSection(
                        title: "Narasumber",
                        entries: [
                            CreditEntry(
                                name: "Ir. Galuh Adi Insani, S.Pt., M.Sc., IPM.",
                                details: [
                                    """
                                    Agricultural and Veterinary Sciences / \
                                    Genetic and Animal Breeding / \
                                    Animal Genetics and Production
                                    """,
                                    "Fakultas Peternakan UGM"
                                ]
                            )
                        ]
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.vertical, AppSpacing.lg)
            }
            .navigationTitle("Tentang")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func creditSection(
        title: String,
        entries: [CreditEntry]
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(title)
                .font(AppFont.headline)
                .foregroundStyle(AppColor.Text.primary)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                ForEach(entries) { entry in
                    VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                        Text(entry.name)
                            .font(AppFont.body)
                            .foregroundStyle(AppColor.Text.primary)
                        ForEach(entry.details, id: \.self) { detail in
                            Text(detail)
                                .font(AppFont.caption)
                                .foregroundStyle(AppColor.Text.secondary)
                        }
                    }
                }
            }
        }
    }
}

/// One credited person: a name and optional supporting lines.
private struct CreditEntry: Identifiable {
    let name: String
    var details: [String] = []

    var id: String { name }
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
