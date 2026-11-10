//
//  UserProfileRepository.swift
//  CattleFarmz
//

import Foundation

/// Storage abstraction for the single user profile row.
@MainActor
protocol UserProfileRepository {
    /// The stored profile, or `nil` before onboarding completes.
    func profile() throws -> UserProfileConfiguration?
    /// Creates the profile, or updates the existing row, and marks onboarding complete.
    func completeOnboarding(name: String) throws
}
