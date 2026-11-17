//
//  ProfileEditViewModel.swift
//  CattleFarmz
//

import Foundation
import Observation
import PhotosUI
import SwiftUI
import UIKit

/// Backing state for the edit-profile form: name, farm name, and picture.
@Observable
@MainActor
final class ProfileEditViewModel {
    var name: String
    var farmName: String

    /// The currently displayed profile picture, seeded from storage and
    /// replaced when the user picks a new photo.
    private(set) var profileImage: UIImage?

    /// Selected photo from the system picker; loading it converts to a
    /// `UIImage` here so the view never reshapes data.
    var pickerItem: PhotosPickerItem? {
        didSet { loadPickedImage() }
    }

    private(set) var errorMessage: String?
    private(set) var isSaving = false

    private let repository: any UserProfileRepository
    private let toast: ToastManager
    /// Reports a successful save to the `App` layer (which pops the screen).
    private let onSaved: () -> Void

    init(
        repository: any UserProfileRepository,
        toast: ToastManager,
        initialName: String,
        initialFarmName: String,
        initialImage: Data?,
        onSaved: @escaping () -> Void = {}
    ) {
        self.repository = repository
        self.toast = toast
        self.name = initialName
        self.farmName = initialFarmName
        self.profileImage = initialImage.flatMap(UIImage.init(data:))
        self.onSaved = onSaved
    }

    /// Validates the fields, persists the profile, shows a toast, then
    /// reports completion.
    func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Nama wajib diisi."
            return
        }

        guard !isSaving else { return }
        isSaving = true
        errorMessage = nil

        let imageData = profileImage?.jpegData(compressionQuality: 0.85)
        do {
            try repository.updateProfile(
                name: trimmedName,
                farmName: farmName.trimmingCharacters(in: .whitespacesAndNewlines),
                profileImage: imageData
            )
            toast.show("Profil berhasil disimpan")
            onSaved()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }

    private func loadPickedImage() {
        guard let pickerItem else { return }
        Task {
            if let data = try? await pickerItem.loadTransferable(type: Data.self) {
                profileImage = UIImage(data: data)
            }
        }
    }
}
