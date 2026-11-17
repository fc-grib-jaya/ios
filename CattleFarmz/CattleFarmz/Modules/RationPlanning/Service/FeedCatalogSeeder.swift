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
    static let catalogVersion = 2

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
        
        let marker = try context.fetch(markerQuery).first
        if let marker {
            guard (1...Self.catalogVersion).contains(marker.version) else {
                throw SeedError.unsupportedVersion
            }
            let count = try context.fetchCount(FetchDescriptor<StoredFeedIngredient>())
            guard count > 0 else { throw SeedError.missingCatalog }
            if marker.version == Self.catalogVersion { return }
        }

        let csvText = try reader.read()
        var ingredients = try parser.parse(csvText)
        let concentrates = try reader.readConcentrates()
        if !concentrates.isEmpty {
            ingredients += try parser.parseConcentrates(concentrates)
        }
        guard Set(ingredients.map(\.id)).count == ingredients.count else {
            throw FeedCSVParser.ParseError.invalidHeader
        }

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
            
            if let marker {
                marker.version = Self.catalogVersion
            } else {
                context.insert(FeedCatalogSeedState(version: Self.catalogVersion))
            }
            
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
