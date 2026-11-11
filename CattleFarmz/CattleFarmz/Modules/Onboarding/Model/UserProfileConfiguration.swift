//
//  UserProfileConfiguration.swift
//  CattleFarmz
//

import Foundation
import SwiftData

/// Single-row configuration describing the person using the app.
@Model
final class UserProfileConfiguration {
    /// Display name entered during onboarding.
    var name: String
    /// True once onboarding finished. Read once at launch.
    var isOnboarded: Bool

    init(name: String, isOnboarded: Bool = true) {
        self.name = name
        self.isOnboarded = isOnboarded
    }
}
