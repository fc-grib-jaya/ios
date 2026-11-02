//
//  PersistenceController.swift
//  CattleFarmz
//

import Foundation
import SwiftData

enum PersistenceController {
    /// Builds a ModelContainer for the given model types.
    /// - Parameter inMemory: use true for previews and tests.
    static func makeContainer(
        for types: [any PersistentModel.Type],
        inMemory: Bool = false
    ) throws -> ModelContainer {
        let schema = Schema(types)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, configurations: [config])
    }
}
