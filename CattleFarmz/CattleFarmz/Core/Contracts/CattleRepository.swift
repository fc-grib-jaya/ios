//
//  CattleRepository.swift
//  CattleFarmz
//

import Foundation

/// Storage abstraction for cattle records.
@MainActor
protocol CattleRepository {
    /// Returns all cattle, newest acquisitions first.
    func cattles() throws -> [Cattle]
    /// Inserts a new cattle record and saves.
    func add(name: String, dateAcquired: Date, breed: CattleBreed, gender: CattleGender, chestGirth: Double, bodyLength: Double) throws
    /// Deletes a cattle record and saves.
    func delete(_ cattle: Cattle) throws
}
