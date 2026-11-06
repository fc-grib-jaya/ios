//
//  FeedRepository.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 05/11/26.
//

import Foundation
import SwiftData

@MainActor
protocol FeedRepository {
    func ingredients() throws -> [FeedIngredient]
}

@MainActor
final class SwiftDataFeedRepository: FeedRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func ingredients() throws -> [FeedIngredient] {
        let query = FetchDescriptor<StoredFeedIngredient>(
            sortBy: [
                SortDescriptor(\.id)
            ]
        )
        
        let records = try context.fetch(query)
        
        return try records.map {
            try $0.ingredient()
        }
    }
}
