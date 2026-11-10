//
//  GuestLoginSheetViewModel.swift
//  CattleFarmz
//

import Foundation
import Observation

/// Persists the guest name and reports completion to the `App` layer.
@Observable
@MainActor
final class GuestLoginSheetViewModel {
    let title = "Masuk sebagai tamu"
    var name = ""
    private(set) var errorMessage: String?

    private let repository: any UserProfileRepository
    private let onDone: () -> Void

    init(
        repository: any UserProfileRepository,
        onDone: @escaping () -> Void = {}
    ) {
        self.repository = repository
        self.onDone = onDone
    }

    /// Validates the name, persists the profile, then reports completion.
    func submit() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            errorMessage = "Nama wajib diisi."
            return
        }

        do {
            try repository.completeOnboarding(name: trimmed)
            errorMessage = nil
            onDone()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
