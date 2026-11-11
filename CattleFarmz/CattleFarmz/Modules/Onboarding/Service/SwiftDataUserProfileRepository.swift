//
//  SwiftDataUserProfileRepository.swift
//  CattleFarmz
//

import Foundation
import SwiftData

/// SwiftData-backed implementation of `UserProfileRepository`.
@MainActor
final class SwiftDataUserProfileRepository: UserProfileRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func profile() throws -> UserProfileConfiguration? {
        var descriptor = FetchDescriptor<UserProfileConfiguration>()
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    func completeOnboarding(name: String) throws {
        if let profile = try profile() {
            profile.name = name
            profile.isOnboarded = true
        } else {
            context.insert(UserProfileConfiguration(name: name))
        }

        try context.save()
    }
}
