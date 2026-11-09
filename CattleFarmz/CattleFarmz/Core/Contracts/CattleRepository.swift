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
    func add(name: String, dateAcquired: Date, breed: CattleBreed, gender: CattleGender, recordedAge: Int, chestGirth: Double?, bodyLength: Double?, bodyWeight: Double?, cattleImage: Data?, notes: String?) throws
    /// Deletes a cattle record and saves.
    func delete(_ cattle: Cattle) throws
    
    func update(
        for cattleID: UUID,
        name: String,
        dateAcquired: Date,
        breed: CattleBreed,
        gender: CattleGender,
        recordedAge: Int,
        chestGirth: Double?,
        bodyLength: Double?,
        bodyWeight: Double?,
        notes: String?
    ) throws
    
    func updateMeasurement(for cattleID: UUID, chestGirth: Double, bodyLength: Double) throws
    
    func updateWeight(for cattleID: UUID, bodyWeight: Double) throws
    
    func updateNotes(for cattleID: UUID, notes: String) throws
}
