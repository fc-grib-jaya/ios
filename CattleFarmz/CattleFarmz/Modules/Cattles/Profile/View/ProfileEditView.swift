//
//  ProfileEditView.swift
//  CattleFarmz
//

import PhotosUI
import SwiftUI

/// Pushed form for editing the profile picture, display name, and farm name.
struct ProfileEditView: View {
    @State private var viewModel: ProfileEditViewModel
    @State private var isPickerPresented = false

    /// Side length of the editable profile picture.
    private static let avatarSize: CGFloat = 120

    init(viewModel: ProfileEditViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        // Local bindable wrapper so form fields can bind with `$`.
        @Bindable var viewModel = viewModel

        return ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Profile picture with a picker affordance.
                Button {
                    isPickerPresented = true
                } label: {
                    avatarImage
                        .overlay(alignment: .bottomTrailing) {
                            Image(systemName: "pencil.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(
                                    AppColor.Button.Primary.background,
                                    AppColor.Primitive.Base.white
                                )
                        }
                }
                .buttonStyle(.plain)

                editField(
                    title: "Nama",
                    placeholder: "Tuliskan Nama",
                    text: $viewModel.name
                )

                editField(
                    title: "Nama Peternakan",
                    placeholder: "Tuliskan Nama Peternakan",
                    text: $viewModel.farmName
                )

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(AppFont.caption)
                        .foregroundStyle(Color.red)
                }

                Button {
                    viewModel.save()
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                            .tint(AppColor.Button.Primary.foreground)
                    } else {
                        Text("Simpan")
                    }
                }
                .appButtonStyle(.primary)
                .disabled(viewModel.isSaving)
            }
            .padding(AppSpacing.md)
        }
        .navigationTitle("Ubah Profil")
        .navigationBarTitleDisplayMode(.inline)
        .photosPicker(
            isPresented: $isPickerPresented,
            selection: $viewModel.pickerItem,
            matching: .images
        )
    }

    @ViewBuilder
    private var avatarImage: some View {
        if let image = viewModel.profileImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: Self.avatarSize, height: Self.avatarSize)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: Self.avatarSize, height: Self.avatarSize)
                .foregroundStyle(AppColor.Button.Primary.background)
        }
    }

    /// One labeled text field, styled like the onboarding name field.
    private func editField(
        title: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppFont.body)
                .foregroundStyle(AppColor.Text.primary)

            TextField(placeholder, text: text)
                .font(AppFont.body)
                .autocorrectionDisabled()
                .padding(AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 23)
                        .fill(AppColor.Input.background)
                )
        }
    }
}

#Preview {
    NavigationStack {
        ProfileEditView(
            viewModel: ProfileEditViewModel(
                repository: MockUserProfileRepository(
                    profile: UserProfileConfiguration(name: "Tono")
                ),
                toast: ToastManager(),
                initialName: "Tono",
                initialFarmName: "Peternakan Tono",
                initialImage: nil
            )
        )
    }
}
