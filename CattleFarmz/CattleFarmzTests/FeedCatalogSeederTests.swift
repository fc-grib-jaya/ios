//
//  FeedCatalogSeederTests.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 05/11/26.
//

import Foundation
import SwiftData
import Testing
@testable import CattleFarmz

@MainActor
struct FeedCatalogSeederTests {
    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            StoredFeedIngredient.self,
            FeedCatalogSeedState.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }

    private func counts(
        in container: ModelContainer
    ) throws -> (feeds: Int, markers: Int) {
        let context = ModelContext(container)

        let feeds = try context.fetchCount(
            FetchDescriptor<StoredFeedIngredient>()
        )

        let markers = try context.fetchCount(
            FetchDescriptor<FeedCatalogSeedState>()
        )

        return (feeds, markers)
    }

    @Test
    func seedsOnceAndSkipsTheNextRead() throws {
        let container = try makeContainer()
        let reader = TestFeedCSVReader(text: Self.validCSV)

        let firstSeeder = FeedCatalogSeeder(
            container: container,
            reader: reader,
            parser: FeedCSVParser()
        )

        try firstSeeder.seedIfNeeded()

        let firstCounts = try counts(in: container)

        #expect(firstCounts.feeds == 2)
        #expect(firstCounts.markers == 1)
        #expect(reader.readCount == 1)

        // A new seeder must use the saved marker.
        let secondSeeder = FeedCatalogSeeder(
            container: container,
            reader: reader,
            parser: FeedCSVParser()
        )

        try secondSeeder.seedIfNeeded()

        let secondCounts = try counts(in: container)

        #expect(secondCounts.feeds == 2)
        #expect(secondCounts.markers == 1)
        #expect(reader.readCount == 1)
    }

    @Test
    func invalidCSVLeavesNoDataAndCanBeRetried() throws {
        let container = try makeContainer()

        let reader = TestFeedCSVReader(
            text: Self.validCSV.replacingOccurrences(
                of: "10.2",
                with: "invalid-number"
            )
        )

        let seeder = FeedCatalogSeeder(
            container: container,
            reader: reader,
            parser: FeedCSVParser()
        )

        #expect(throws: FeedCSVParser.ParseError.self) {
            try seeder.seedIfNeeded()
        }

        let failedCounts = try counts(in: container)

        #expect(failedCounts.feeds == 0)
        #expect(failedCounts.markers == 0)

        // Correct the input and retry the same seeder.
        reader.text = Self.validCSV

        try seeder.seedIfNeeded()

        let successfulCounts = try counts(in: container)

        #expect(successfulCounts.feeds == 2)
        #expect(successfulCounts.markers == 1)
        #expect(reader.readCount == 2)
    }

    @Test
    func conflictRollsBackPendingInserts() throws {
        let container = try makeContainer()

        let parsed = try FeedCSVParser().parse(Self.validCSV)

        // Store a conflicting second ingredient before seeding.
        let existing = StoredFeedIngredient(
            ingredient: parsed[1]
        )

        existing.name = "User-edited feed"

        let setupContext = ModelContext(container)
        setupContext.insert(existing)
        try setupContext.save()

        let reader = TestFeedCSVReader(text: Self.validCSV)

        let seeder = FeedCatalogSeeder(
            container: container,
            reader: reader,
            parser: FeedCSVParser()
        )

        #expect(throws: FeedCatalogSeeder.SeedError.self) {
            try seeder.seedIfNeeded()
        }

        // The first ingredient's pending insertion must be rolled back.
        let remainingCounts = try counts(in: container)

        #expect(remainingCounts.feeds == 1)
        #expect(remainingCounts.markers == 0)

        let verificationContext = ModelContext(container)

        let remaining = try verificationContext.fetch(
            FetchDescriptor<StoredFeedIngredient>()
        )

        #expect(remaining.first?.id == parsed[1].id)
        #expect(remaining.first?.name == "User-edited feed")
    }

    private static let validCSV = """
    Nama Pakan,Jenis Hewan,Kategori,Protein (%),TDN (%),Ca (%),P (%),Mg (%),Fe (ppm),Cu (ppm),Zn (ppm)
    Rumput Gajah,Sapi,Hijauan,10.2,55,0.5,0.3,0.2,250,10,40
    Bungkil Kedelai,Sapi,Konsentrat,42,75,0.3,0.6,0.3,120,15,50
    """
}

@MainActor
private final class TestFeedCSVReader: FeedCSVReading {
    var text: String
    private(set) var readCount = 0

    init(text: String) {
        self.text = text
    }

    func read() throws -> String {
        readCount += 1
        return text
    }
}
