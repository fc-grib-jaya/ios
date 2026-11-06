//
//  FeedCatalogSeeder.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 05/11/26.
//


import Foundation
import SwiftData

@MainActor
final class FeedCatalogSeeder {
    private let container: ModelContainer
    private let reader: any FeedCSVReading
    private let parser: FeedCSVParser
    
    init(
        container: ModelContainer,
        reader: any FeedCSVReading,
        parser: FeedCSVParser
    ) {
        self.container = container
        self.reader = reader
        self.parser = parser
    }
    
    func seedIfNeeded() throws {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        
        let markerQuery = FetchDescriptor<FeedCatalogSeedState>(
            predicate: #Predicate {
                $0.key == "feed-catalog"
            }
        )
        
        if let marker = try context.fetch(markerQuery).first {
            guard marker.version == 1 else {
                throw SeedError.unsupportedVersion
            }
            
            let count = try context.fetchCount(
                FetchDescriptor<StoredFeedIngredient>()
            )
            
            guard count > 0 else {
                throw SeedError.missingCatalog
            }
            
            return
        }
        
        let csvText = try reader.read()
        let ingredients = try parser.parse(csvText)
        
        do {
            let existingRecords = try context.fetch(
                FetchDescriptor<StoredFeedIngredient>()
            )
            
            let existingByID = Dictionary(
                uniqueKeysWithValues: existingRecords.map {
                    ($0.id, $0)
                }
            )
            
            for ingredient in ingredients {
                if let existing = existingByID[ingredient.id] {
                    guard try existing.ingredient() == ingredient else {
                        throw SeedError.conflictingIngredient(
                            ingredient.id
                        )
                    }
                } else {
                    context.insert(
                        StoredFeedIngredient(
                            ingredient: ingredient
                        )
                    )
                }
            }
            
            context.insert(
                FeedCatalogSeedState(version: 1)
            )
            
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
    
    enum SeedError: LocalizedError {
        case unsupportedVersion
        case missingCatalog
        case conflictingIngredient(String)
        
        var errorDescription: String? {
            switch self {
            case .unsupportedVersion:
                return "The stored feed catalog version is not supported."
                
            case .missingCatalog:
                return "The catalog is marked as initialized, but its records are missing."
                
            case .conflictingIngredient(let id):
                return "Existing feed data conflicts with the CSV for \(id). No changes were saved."
            }
        }
    }
}
