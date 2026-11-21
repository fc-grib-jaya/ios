//
//  SwiftDataCattleRepository.swift
//  CattleFarmz
//

import Foundation
import SwiftData

/// SwiftData-backed implementation of `CattleRepository`.
@MainActor
final class SwiftDataCattleRepository: CattleRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func cattles() throws -> [Cattle] {
        let descriptor = FetchDescriptor<Cattle>(
            sortBy: [SortDescriptor(\.dateAcquired, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func add(
        name: String,
        dateAcquired: Date,
        breed: CattleBreed,
        gender: CattleGender,
        recordedAge: Int,
        chestGirth: Double?,
        bodyLength: Double?,
        bodyWeight: Double?,
        cattleImage: Data?,
        notes: String?
    ) throws {
        let cattle = Cattle(
            name: name,
            dateAcquired: dateAcquired,
            breed: breed,
            gender: gender,
            recordedAge: recordedAge,
            chestGirth: chestGirth,
            bodyLength: bodyLength,
            bodyWeight: bodyWeight,
            cattleImage: cattleImage,
            notes: notes
        )
        CattleWeightProgressViewModel.createInitialProgress(for: cattle)
        context.insert(cattle)
        try saveChanges()
    }

    func delete(_ cattle: Cattle) throws {
        context.delete(cattle)
        try saveChanges()
    }
    
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
        cattleImage: Data?,
        notes: String?
    ) throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              recordedAge >= 0,
              chestGirth == nil || (chestGirth?.isFinite == true && chestGirth! > 0),
              bodyLength == nil || (bodyLength?.isFinite == true && bodyLength! > 0),
              bodyWeight == nil || (bodyWeight?.isFinite == true && bodyWeight! > 0 && bodyWeight! <= 9_999)
        else {
            throw CattleRepositoryError.invalidMeasurement
        }

        let cattle = try findCattle(for: cattleID)
        try CattleWeightProgressViewModel.recordEditedProgress(
            for: cattle, bodyWeight: bodyWeight, chestGirth: chestGirth,
            bodyLength: bodyLength, breed: breed, gender: gender
        )
        cattle.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        cattle.dateAcquired = dateAcquired
        cattle.breed = breed
        cattle.gender = gender
        cattle.recordedAge = recordedAge
        cattle.chestGirth = chestGirth
        cattle.bodyLength = bodyLength
        cattle.cattleImage = cattleImage
        cattle.notes = notes?.trimmingCharacters(in: .whitespacesAndNewlines)
        try saveChanges()
    }

    private func saveChanges() throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    private func findCattle(for cattleID: UUID) throws -> Cattle {
        var descriptor = FetchDescriptor<Cattle>(
            predicate: #Predicate<Cattle> { cattle in
                cattle.id == cattleID
            }
        )
        descriptor.fetchLimit = 1

        guard let cattle = try context.fetch(descriptor).first else {
            throw CattleRepositoryError.cattleNotFound
        }

        return cattle
    }
    
    func updateMeasurement(for cattleID: UUID, chestGirth: Double, bodyLength: Double) throws {
        guard chestGirth.isFinite, chestGirth > 0,
              bodyLength.isFinite, bodyLength > 0 else {
            throw CattleRepositoryError.invalidMeasurement
        }
        
        let cattle = try findCattle(for: cattleID)
        
        try CattleWeightProgressViewModel.recordMeasurement(
            for: cattle, chestGirth: chestGirth, bodyLength: bodyLength
        )
        cattle.chestGirth = chestGirth
        cattle.bodyLength = bodyLength
        try saveChanges()
    }
    
    func updateWeight(for cattleID: UUID, bodyWeight: Double) throws {
        guard bodyWeight.isFinite, bodyWeight > 0 else {
            throw CattleRepositoryError.invalidWeight
        }

        let cattle = try findCattle(for: cattleID)

        try CattleWeightProgressViewModel.recordProgress(for: cattle, weight: bodyWeight)
        try saveChanges()
    }
    
    func updateNotes(for cattleID: UUID, notes: String) throws {
        let cattle = try findCattle(for: cattleID)

        cattle.notes = notes
        
        try saveChanges()
    }
}
