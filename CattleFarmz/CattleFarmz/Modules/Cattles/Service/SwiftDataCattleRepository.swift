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
        chestGirth: Double,
        bodyLength: Double
    ) throws {
        context.insert(
            Cattle(
                name: name,
                dateAcquired: dateAcquired,
                breed: breed,
                gender: gender,
                chestGirth: chestGirth,
                bodyLength: bodyLength
            )
        )
        try context.save()
    }

    func delete(_ cattle: Cattle) throws {
        context.delete(cattle)
        try context.save()
    }
}
