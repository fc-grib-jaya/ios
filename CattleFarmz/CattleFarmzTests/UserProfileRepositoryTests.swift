//
//  UserProfileRepositoryTests.swift
//  CattleFarmzTests
//

import Testing
import SwiftData
@testable import CattleFarmz

@MainActor
struct UserProfileRepositoryTests {
    @Test
    func completingOnboardingKeepsASingleRow() throws {
        let container = try PersistenceController.makeContainer(
            for: [UserProfileConfiguration.self],
            inMemory: true
        )
        let repository = SwiftDataUserProfileRepository(
            context: container.mainContext
        )

        #expect(try repository.profile() == nil)

        try repository.completeOnboarding(name: "Tono")
        try repository.completeOnboarding(name: "Budi")

        let rows = try container.mainContext.fetch(
            FetchDescriptor<UserProfileConfiguration>()
        )

        #expect(rows.count == 1)
        #expect(rows.first?.name == "Budi")
        #expect(rows.first?.isOnboarded == true)
    }
}
