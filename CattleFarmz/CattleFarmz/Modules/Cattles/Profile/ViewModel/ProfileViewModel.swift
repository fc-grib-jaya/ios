//
//  ProfileViewModel.swift
//  CattleFarmz
//

import Foundation
import Observation
import UIKit

/// Backing model for the profile screen.
@Observable
@MainActor
final class ProfileViewModel {
    /// Display name shown under the avatar.
    private(set) var name: String = "Tamu"
    /// Farm name shown as the subtitle; empty when not set.
    private(set) var farmName: String = ""
    private(set) var profileImage: UIImage?

    private let repository: any UserProfileRepository

    init(repository: any UserProfileRepository) {
        self.repository = repository
    }

    /// Re-reads the stored profile; called when the screen appears so edits
    /// made on the edit page are reflected without recreating the view
    /// (the tab's `@State` survives across re-renders).
    func load() {
        let profile = try? repository.profile()
        name = profile?.name ?? "Tamu"
        farmName = profile?.farmName ?? ""
        profileImage = profile?.profileImage.flatMap(UIImage.init(data:))
    }
}
