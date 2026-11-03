//
//  CattleRepository.swift
//  CattleFarmz
//

import Foundation

enum CattleRepositoryError: Error {
    case cattleNotFound
    case invalidMeasurement
    case invalidWeight
}

/// Storage abstraction for cattle records.
@MainActor
protocol CattleRepository {
    /// Returns all cattle, newest acquisitions first.
    func cattles() throws -> [Cattle]
    /// Inserts a new cattle record and saves.
    func add(name: String, dateAcquired: Date, breed: CattleBreed, gender: CattleGender) throws
    /// Deletes a cattle record and saves.
    func delete(_ cattle: Cattle) throws
    
    func updateMeasurement(for cattleID: UUID, chestGirth: Double, bodyLength: Double) throws
    
    func updateWeight(for cattleID: UUID, bodyWeight: Double) throws
}
