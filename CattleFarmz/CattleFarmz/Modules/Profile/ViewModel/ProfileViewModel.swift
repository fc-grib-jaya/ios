//
//  ProfileViewModel.swift
//  CattleFarmz
//

import Foundation
import Observation

/// Backing model for the profile screen.
///
/// Holds placeholder data: authentication and real user data are out of scope.
@Observable
@MainActor
final class ProfileViewModel {
    /// Profile currently displayed.
    let profile: UserProfile

    init(profile: UserProfile = UserProfile(name: "Jane Doe", email: "jane.doe@example.com")) {
        self.profile = profile
    }
}
