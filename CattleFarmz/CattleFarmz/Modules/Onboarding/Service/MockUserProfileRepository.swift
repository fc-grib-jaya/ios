//
//  MockUserProfileRepository.swift
//  CattleFarmz
//

import Foundation

/// In-memory implementation of `UserProfileRepository` for previews and tests.
@MainActor
final class MockUserProfileRepository: UserProfileRepository {
    private var stored: UserProfileConfiguration?

    init(profile: UserProfileConfiguration? = nil) {
        self.stored = profile
    }

    func profile() throws -> UserProfileConfiguration? {
        stored
    }

    func completeOnboarding(name: String) throws {
        if let stored {
            stored.name = name
            stored.isOnboarded = true
        } else {
            stored = UserProfileConfiguration(name: name)
        }
    }
}
