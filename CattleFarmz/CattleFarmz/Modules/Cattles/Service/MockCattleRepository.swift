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

    func add(name: String, dateAcquired: Date, breed: CattleBreed, gender: CattleGender, chestGirth: Double, bodyLength: Double) throws {
        items.append(Cattle(name: name, dateAcquired: dateAcquired, breed:  breed, gender: gender, chestGirth: chestGirth, bodyLength: bodyLength))
    }

    func delete(_ cattle: Cattle) throws {
        items.removeAll { $0.id == cattle.id }
    }
}

extension Cattle {
    static let samples: [Cattle] = [
        Cattle(name: "Sapi 1", dateAcquired: .now, breed: .aceh, gender: .male, chestGirth: 175, bodyLength: 150),
        Cattle(name: "Sapi 2", dateAcquired: .now.addingTimeInterval(-86_400 * 30), breed: .friesianHolstein, gender: .female, chestGirth: 200, bodyLength: 180)
    ]
}
