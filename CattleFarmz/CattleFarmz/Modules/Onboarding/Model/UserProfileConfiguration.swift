//
//  UserProfileConfiguration.swift
//  CattleFarmz
//

import Foundation
import SwiftData

/// Single-row configuration describing the person using the app.
@Model
final class UserProfileConfiguration {
    /// Display name entered during onboarding or edited on the profile page.
    var name: String
    /// Name of the user's farm, edited on the profile page.
    var farmName: String
    /// Profile picture chosen on the profile page, as JPEG data.
    var profileImage: Data?
    /// True once onboarding finished. Read once at launch.
    var isOnboarded: Bool

    init(
        name: String,
        farmName: String = "",
        profileImage: Data? = nil,
        isOnboarded: Bool = true
    ) {
        self.name = name
        self.farmName = farmName
        self.profileImage = profileImage
        self.isOnboarded = isOnboarded
    }
}
