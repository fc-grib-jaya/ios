//
//  ProfileView.swift
//  CattleFarmz
//

import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @State private var isAboutPresented = false
    private let onEditTap: () -> Void

    init(
        viewModel: ProfileViewModel,
        onEditTap: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onEditTap = onEditTap
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                LinearGradient(
                    colors: [
                        AppColor.Primitive.Secondary.shade100,
                        AppColor.Surface.canvas,
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: geometry.size.height * 0.3)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .background(AppColor.Surface.canvas)
            .ignoresSafeArea()
            
            GeometryReader { geometry in
//                ScrollView {
                    VStack {
                        ProfileIdentityHeader(
                            image: viewModel.profileImage,
                            name: viewModel.name,
                            farmName: viewModel.farmName,
                            onEditTap: onEditTap
                        )
                        
                        ProfileAboutRow {
                            isAboutPresented = true
                        }
                        .padding(.horizontal, AppSpacing.xl)
                        
                        Spacer(minLength: AppSpacing.xl)
                        
                        LemooFooter()
                            .padding(.bottom, AppSpacing.xl)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geometry.size.height)
//                }
            }
        }
        .navigationTitle("Profil")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isAboutPresented) {
            AboutSheetView()
        }
        .task { viewModel.load() }
    }
}

private struct ProfileIdentityHeader: View {
    let image: UIImage?
    let name: String
    let farmName: String
    let onEditTap: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Group {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(AppColor.Button.Primary.background)
                        .background(AppColor.Surface.card)
                }
            }
            .frame(width: 180, height: 180)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(.white, lineWidth: 2))
            .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
            .accessibilityHidden(true)
            .padding(.top, AppSpacing.massive)

            VStack(spacing: AppSpacing.xs) {
                Text(name)
                    .font(AppFont.largeTitle)
                    .foregroundStyle(AppColor.Text.primary)
                    .accessibilityAddTraits(.isHeader)

                if !farmName.isEmpty {
                    Label(farmName, systemImage: "leaf")
                        .font(AppFont.mediumSubheadline)
                        .foregroundStyle(AppColor.Text.secondary)
                }
            }
            .padding(.bottom, AppSpacing.xxl)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)

            Button(action: onEditTap) {
                Label("Ubah Profil", systemImage: "pencil")
                    .font(AppFont.headline)
            }
            .appButtonStyle(.primary)
            .foregroundStyle(AppColor.Text.primary)
        }
        .padding(.horizontal, AppSpacing.xl)
        .padding(.vertical, AppSpacing.xxs)
        .frame(maxWidth: .infinity)
    }
}

private struct ProfileAboutRow: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "info.circle")
                    .accessibilityHidden(true)
                Text("Tentang Lemoo")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppColor.Text.secondary)
                    .accessibilityHidden(true)
            }
            .font(AppFont.body)
            .foregroundStyle(AppColor.Text.primary)
            .padding(.horizontal, AppSpacing.lg)
            .frame(minHeight: 56)
            .background(AppColor.Surface.card, in: .rect(cornerRadius: 20))
            .contentShape(.rect(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}

private struct LemooFooter: View {
    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Text("Lemoo")
            Text("© \(String(Calendar.current.component(.year, from: .now))) GRIB, All Right Reserved")
                .foregroundStyle(AppColor.Text.secondary)
        }
        .font(AppFont.caption)
        .foregroundStyle(AppColor.Text.secondary)
        .multilineTextAlignment(.center)
    }
}

private struct AboutSheetView: View {
    @Environment(\.dismiss) private var dismiss

    private static let developers = [
        CreditEntry(name: "Ahmad Yasri Zaenuri"),
        CreditEntry(name: "DF Bomanarakasura"),
        CreditEntry(name: "Dylan Amadeus"),
        CreditEntry(name: "Fajari Bagas"),
        CreditEntry(name: "Salman Alfarizi Ramadhan"),
        CreditEntry(name: "Yuan Dimianta")
    ]

    private static let advisors = [
        CreditEntry(
            name: "Ir. Galuh Adi Insani, S.Pt., M.Sc., IPM.",
            details: [
                "Agricultural and Veterinary Sciences / Genetic and Animal Breeding / Animal Genetics and Production",
                "Fakultas Peternakan UGM"
            ]
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    LemooIntroductionHeader()
                    AboutCreditSection(title: "Tim Pengembang", entries: Self.developers)
                    AboutCreditSection(title: "Narasumber", entries: Self.advisors)
                }
                .padding(AppSpacing.xl)
            }
            .background(AppColor.Surface.canvas.ignoresSafeArea())
            .navigationTitle("Tentang Lemoo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Tutup")
                            .frame(minWidth: 44, minHeight: 44)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

private struct LemooIntroductionHeader: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image("LemooAppIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 88, height: 88)
                .clipShape(.rect(cornerRadius: 20))
                .accessibilityHidden(true)

            VStack(spacing: AppSpacing.xs) {
                Text("Lemoo")
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.Text.primary)
                    .accessibilityAddTraits(.isHeader)
                Text("© \(String(Calendar.current.component(.year, from: .now))) GRIB, All Right Reserved")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.Text.secondary)
            }

            Text("Pantau pertumbuhan dan rencanakan ransum sapi dengan pengukuran melalui kamera.")
                .font(AppFont.body)
                .foregroundStyle(AppColor.Text.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

private struct AboutCreditSection: View {
    let title: LocalizedStringResource
    let entries: [CreditEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(title)
                .font(AppFont.headline)
                .foregroundStyle(AppColor.Text.primary)
                .accessibilityAddTraits(.isHeader)

            ForEach(entries) { entry in
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(entry.name)
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.Text.primary)
                    ForEach(entry.details, id: \.self) { detail in
                        Text(detail)
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.Text.secondary)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.lg)
        .background(AppColor.Surface.card, in: .rect(cornerRadius: 20))
    }
}

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

#Preview("About • Accessibility") {
    AboutSheetView()
        .environment(\.dynamicTypeSize, .accessibility3)
}
