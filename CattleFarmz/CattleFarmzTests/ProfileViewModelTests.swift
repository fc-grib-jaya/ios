//
//  ProfileViewModelTests.swift
//  CattleFarmzTests
//

import Testing
import SwiftData
@testable import CattleFarmz

@MainActor
struct ProfileViewModelTests {
    @Test
    func showsTheNameCapturedDuringOnboarding() throws {
        let container = try PersistenceController.makeContainer(
            for: [UserProfileConfiguration.self],
            inMemory: true
        )
        let repository = SwiftDataUserProfileRepository(
            context: container.mainContext
        )
        try repository.completeOnboarding(name: "Tono")

        #expect(ProfileViewModel(repository: repository).name == "Tono")
    }

    @Test
    func fallsBackToGuestBeforeOnboarding() {
        #expect(
            ProfileViewModel(repository: MockUserProfileRepository()).name
                == "Tamu"
        )
    }
}
