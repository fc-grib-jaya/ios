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
    /// True while the profile is being persisted; the submit button shows a
    /// loading spinner and ignores taps.
    private(set) var isSubmitting = false

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
    ///
    /// Persistence runs after a short pause so the button's loading state is
    /// visible; the sheet closes and the main interface appears in `onDone`.
    func submit() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            errorMessage = "Nama wajib diisi."
            return
        }

        guard !isSubmitting else { return }
        isSubmitting = true
        errorMessage = nil

        Task {
            // Let the loading spinner render before persisting.
            try? await Task.sleep(for: .milliseconds(400))

            do {
                try repository.completeOnboarding(name: trimmed)
                onDone()
            } catch {
                isSubmitting = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
