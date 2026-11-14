//
//  MockCattleRepository.swift
//  CattleFarmz
//

import Foundation

/// In-memory implementation of `CattleRepository` for previews and tests.
@MainActor
final class MockCattleRepository: CattleRepository {
    private var items: [Cattle]

    init(items: [Cattle] = Cattle.samples) {
        self.items = items
    }

    func cattles() throws -> [Cattle] {
        items.sorted { $0.dateAcquired > $1.dateAcquired }
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
        items.append(
            Cattle(
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
        )
    }

    func delete(_ cattle: Cattle) throws {
        items.removeAll { $0.id == cattle.id }
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
        notes: String?
    ) throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              recordedAge >= 0,
              chestGirth == nil || (chestGirth?.isFinite == true && chestGirth! > 0),
              bodyLength == nil || (bodyLength?.isFinite == true && bodyLength! > 0),
              bodyWeight == nil || (bodyWeight?.isFinite == true && bodyWeight! > 0),
              let cattle = items.first(where: { $0.id == cattleID })
        else {
            throw CattleRepositoryError.invalidMeasurement
        }

        cattle.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        cattle.dateAcquired = dateAcquired
        cattle.breed = breed
        cattle.gender = gender
        cattle.recordedAge = recordedAge
        cattle.chestGirth = chestGirth
        cattle.bodyLength = bodyLength
        cattle.bodyWeight = bodyWeight
        cattle.notes = notes?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func updateMeasurement(
        for cattleID: UUID,
        chestGirth: Double,
        bodyLength: Double
    ) throws {
        guard chestGirth.isFinite, chestGirth > 0,
            bodyLength.isFinite, bodyLength > 0
        else {
            throw CattleRepositoryError.invalidMeasurement
        }

        guard let cattle = items.first(where: { $0.id == cattleID }) else {
            throw CattleRepositoryError.cattleNotFound
        }

        cattle.chestGirth = chestGirth
        cattle.bodyLength = bodyLength
    }

    func updateWeight(for cattleID: UUID, bodyWeight: Double) throws {
        guard bodyWeight.isFinite, bodyWeight > 0 else {
            throw CattleRepositoryError.invalidWeight
        }

        guard let cattle = items.first(where: { $0.id == cattleID }) else {
            throw CattleRepositoryError.cattleNotFound
        }

        cattle.bodyWeight = bodyWeight
    }

    func updateNotes(for cattleID: UUID, notes: String) throws {
        guard let cattle = items.first(where: { $0.id == cattleID }) else {
            throw CattleRepositoryError.cattleNotFound
        }

        cattle.notes = notes
    }
}

extension Cattle {
    static let samples: [Cattle] = [
        Cattle(
            name: "Sapi 1",
            dateAcquired: .now,
            breed: .aceh,
            gender: .male,
            recordedAge: 10,
            chestGirth: 175,
            bodyLength: 150
        ),
        Cattle(
            name: "Sapi 2",
            dateAcquired: .now.addingTimeInterval(-86_400 * 300),
            breed: .friesianHolstein,
            gender: .female,
            recordedAge: 10,
            bodyWeight: 500
        ),
        Cattle(
            name: "Sapi 3",
            dateAcquired: .now.addingTimeInterval(-86_400 * 35),
            breed: .bali,
            gender: .male,
            recordedAge: 24
        ),
    ]
}
