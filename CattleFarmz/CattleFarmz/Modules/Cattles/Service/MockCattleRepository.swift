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

    func add(name: String, dateAcquired: Date, breed: CattleBreed, gender: CattleGender) throws {
        items.append(Cattle(name: name, dateAcquired: dateAcquired, breed:  breed, gender: gender))
    }

    func delete(_ cattle: Cattle) throws {
        items.removeAll { $0.id == cattle.id }
    }
    
    func updateMeasurement(for cattleID: UUID, chestGirth: Double, bodyLength: Double) throws {
        guard chestGirth.isFinite, chestGirth > 0,
              bodyLength.isFinite, bodyLength > 0 else {
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
}

extension Cattle {
    static let samples: [Cattle] = [
        Cattle(name: "Sapi 1", dateAcquired: .now, breed: .aceh, gender: .male, chestGirth: 175, bodyLength: 150),
        Cattle(name: "Sapi 2", dateAcquired: .now.addingTimeInterval(-86_400 * 30), breed: .friesianHolstein, gender: .female, chestGirth: 200, bodyLength: 180, bodyWeight: 500),
        Cattle(name: "Sapi 3", dateAcquired: .now.addingTimeInterval(-86_400 * 35), breed: .bali, gender: .male)
    ]
}
