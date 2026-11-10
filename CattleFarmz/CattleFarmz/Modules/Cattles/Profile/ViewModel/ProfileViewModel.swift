//
//  ProfileViewModel.swift
//  CattleFarmz
//

import Foundation
import Observation

/// Backing model for the profile screen.
@Observable
@MainActor
final class ProfileViewModel {
    /// Name captured during onboarding.
    private(set) var name: String

    /// Reads the stored name once; the profile screen is rebuilt per appearance.
    init(repository: any UserProfileRepository) {
        name = (try? repository.profile())?.name ?? "Tamu"
    }
}
