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

    @Test
    func bundledConcentratesKeepUnknownValuesAndProductSpecificTDN() throws {
        let reader = BundledFeedCSVReader()
        let parser = FeedCSVParser()
        let brands = try parser.parseConcentrates(reader.readConcentrates())
        #expect(brands.count == 32)
        #expect(Set(brands.map(\.id)).count == 32)
        #expect(brands.filter { $0.nutrients.totalDigestibleNutrientsPercent != nil }.count == 8)
        #expect(brands.filter { $0.nutrients.totalDigestibleNutrientsIsMinimum == true }.count == 4)
        #expect(brands.allSatisfy { $0.nutrients.ironPPM == nil && $0.category == .concentrate })
        let bc132 = try #require(brands.first { $0.name == "Nutrifeed BC 132 - PK 11%" })
        #expect(bc132.nutrients.totalDigestibleNutrientsPercent == 72.4)
        let unknown = try #require(brands.first { $0.name == "Nuansa Baru NBF-3 - PK 16%" })
        #expect(unknown.nutrients.totalDigestibleNutrientsPercent == nil)

        let reversed = try parser.parseConcentrates(
            ([reader.readConcentrates().split(separator: "\n").first!]
             + reader.readConcentrates().split(separator: "\n").dropFirst().reversed())
                .joined(separator: "\n")
        )
        #expect(Set(brands.map(\.id)) == Set(reversed.map(\.id)))
    }

    @Test
    func versionOneCatalogAddsBrandsOnceAndKeepsLegacyIDs() throws {
        let container = try makeContainer()
        let parser = FeedCSVParser()
        let legacy = try parser.parse(Self.validCSV)
        let setup = ModelContext(container)
        for feed in legacy { setup.insert(StoredFeedIngredient(ingredient: feed)) }
        setup.insert(FeedCatalogSeedState(version: 1))
        try setup.save()

        let reader = TestFeedCSVReader(text: Self.validCSV)
        reader.concentrates = Self.brandCSV
        let seeder = FeedCatalogSeeder(container: container, reader: reader, parser: parser)
        try seeder.seedIfNeeded()
        try seeder.seedIfNeeded()

        let context = ModelContext(container)
        let records = try context.fetch(FetchDescriptor<StoredFeedIngredient>())
        #expect(records.count == 3)
        #expect(try records.first { $0.id == legacy[0].id }?.ingredient() == legacy[0])
        #expect(records.first { $0.id == "brand-test-16" }?.totalDigestibleNutrientsPercent == nil)
        #expect(try context.fetch(FetchDescriptor<FeedCatalogSeedState>()).first?.version == 2)
        #expect(reader.readCount == 1)
        #expect(reader.concentrateReadCount == 1)
    }

    @Test
    func invalidBrandUpgradeKeepsVersionOneAndCanRetry() throws {
        let container = try makeContainer()
        let parser = FeedCSVParser()
        let setup = ModelContext(container)
        for feed in try parser.parse(Self.validCSV) { setup.insert(StoredFeedIngredient(ingredient: feed)) }
        setup.insert(FeedCatalogSeedState(version: 1))
        try setup.save()

        let reader = TestFeedCSVReader(text: Self.validCSV)
        reader.concentrates = Self.brandCSV.replacingOccurrences(of: ",16,", with: ",invalid,")
        let seeder = FeedCatalogSeeder(container: container, reader: reader, parser: parser)
        #expect(throws: FeedCSVParser.ParseError.self) { try seeder.seedIfNeeded() }
        #expect(try counts(in: container).feeds == 2)
        let verification = ModelContext(container)
        #expect(try verification.fetch(FetchDescriptor<FeedCatalogSeedState>()).first?.version == 1)
        reader.concentrates = Self.brandCSV
        try seeder.seedIfNeeded()
        #expect(try counts(in: container).feeds == 3)
    }

    @Test
    func missingTDNContributesZeroWithoutLosingProteinOrOldSnapshots() throws {
        let parser = FeedCSVParser()
        let known = try parser.parse(Self.validCSV)[0]
        let unknown = try parser.parseConcentrates(Self.brandCSV)[0]
        let calculator = ManualRationCalculator { _ in
            CattleNutritionDefaults.requirements(for: .beef, stage: .adult)
        }
        let profile = CattleRationProfile()
        let result = try calculator.calculate(profile: profile, items: [
            RationItem(ingredient: known, kilogramsPerAnimalPerDay: 10),
            RationItem(ingredient: unknown, kilogramsPerAnimalPerDay: 10)
        ])
        #expect(abs(result.nutrients.crudeProteinPercent - 13.1) < 0.000001)
        #expect(result.nutrients.totalDigestibleNutrientsPercent == 27.5)
        #expect(result.nutrients.totalDigestibleNutrientsIsPartial == true)
        #expect(result.tdnKilogramsPerAnimalPerDay == 5.5)
        #expect(NutrientComparison.rows(for: result).first { $0.name == "TDN" }?.coverage != nil)
        let roundTrip = try JSONDecoder().decode(
            RationCalculationResult.self, from: JSONEncoder().encode(result)
        )
        #expect(roundTrip.items[1].ingredient == unknown)

        let knownOnly = try calculator.calculate(profile: profile, items: [
            RationItem(ingredient: known, kilogramsPerAnimalPerDay: 10),
            RationItem(ingredient: unknown, kilogramsPerAnimalPerDay: 0)
        ])
        #expect(knownOnly.nutrients.totalDigestibleNutrientsPercent == 55)
        #expect(knownOnly.tdnKilogramsPerAnimalPerDay == 5.5)

        let oldJSON = """
        {"crudeProteinPercent":10.2,"totalDigestibleNutrientsPercent":55}
        """.data(using: .utf8)!
        let old = try JSONDecoder().decode(NutrientContent.self, from: oldJSON)
        #expect(old.totalDigestibleNutrientsPercent == 55)
        #expect(old.totalDigestibleNutrientsIsMinimum == nil)
    }

    @Test
    func calculatesTDNAndMineralBarsUsingZeroForMissingData() throws {
        let parser = FeedCSVParser()
        let reader = BundledFeedCSVReader()
        let legacy = try parser.parse(reader.read())
        let brands = try parser.parseConcentrates(reader.readConcentrates())
        let grass = try #require(legacy.first { $0.name == "Rumput Gajah" })
        let tofu = try #require(legacy.first { $0.name == "Ampas Tahu" })
        let brand = try #require(brands.first { $0.id == "brand-nuansa-baru-nbf-3" })
        let calculator = ManualRationCalculator { _ in
            CattleNutritionDefaults.requirements(for: .beef, stage: .adult)
        }
        let result = try calculator.calculate(profile: CattleRationProfile(), items: [
            RationItem(ingredient: brand, kilogramsPerAnimalPerDay: 1),
            RationItem(ingredient: grass, kilogramsPerAnimalPerDay: 5),
            RationItem(ingredient: tofu, kilogramsPerAnimalPerDay: 5)
        ])
        #expect(abs((result.nutrients.totalDigestibleNutrientsPercent ?? 0) - (625.0 / 11)) < 1e-9)
        #expect(result.nutrients.totalDigestibleNutrientsIsPartial == true)
        #expect(result.tdnKilogramsPerAnimalPerDay == 6.25)
        #expect(result.kilogramsPerAnimalPerDay == 11)
        #expect(abs((result.nutrients.calciumPercent ?? 0) - 4.0 / 11) < 1e-9)
        let tdn = try #require(NutrientComparison.rows(for: result).first { $0.name == "TDN" })
        #expect(abs((tdn.actual ?? 0) - 625.0 / 11) < 1e-9)
        #expect(tdn.actualIsPartial)
        #expect(abs((tdn.coverage ?? 0) - (625.0 / 11 / 60)) < 1e-9)
        let growing = NutrientComparison(name: "TDN", actual: tdn.actual, minimum: 65, unit: "%", actualIsPartial: true)
        #expect(abs((growing.coverage ?? 0) * 100 - 87.41258741258741) < 1e-8)
        #expect(abs((result.nutrients.ironPPM ?? 0) - 2000.0 / 11) < 1e-8)
        let restored = try JSONDecoder().decode(RationCalculationResult.self, from: JSONEncoder().encode(result))
        #expect(restored.nutrients.totalDigestibleNutrientsIsPartial == true)

        let unknownOnly = try calculator.calculate(profile: CattleRationProfile(), items: [
            RationItem(ingredient: brand, kilogramsPerAnimalPerDay: 1)
        ])
        #expect(unknownOnly.nutrients.totalDigestibleNutrientsPercent == 0)
        #expect(unknownOnly.tdnKilogramsPerAnimalPerDay == 0)
    }

    @Test
    func minimumTDNSurvivesPersistenceAndCalculation() throws {
        let brand = try FeedCSVParser().parseConcentrates(
            Self.brandCSV.replacingOccurrences(of: ",16,,", with: ",16,68,Minimum")
        )[0]
        let container = try makeContainer()
        let setup = ModelContext(container)
        setup.insert(StoredFeedIngredient(ingredient: brand))
        try setup.save()
        let verification = ModelContext(container)
        let stored = try #require(verification.fetch(FetchDescriptor<StoredFeedIngredient>()).first)
        #expect(try stored.ingredient() == brand)
        let result = try ManualRationCalculator { _ in
            CattleNutritionDefaults.requirements(for: .beef, stage: .adult)
        }.calculate(profile: CattleRationProfile(), items: [
            RationItem(ingredient: brand, kilogramsPerAnimalPerDay: 2)
        ])
        #expect(result.nutrients.totalDigestibleNutrientsIsMinimum == true)
        #expect(result.nutrients.totalDigestibleNutrientsPercent == 68)
        #expect(NutrientComparison.rows(for: result).first { $0.name == "TDN" }?.actualIsMinimum == true)
    }

    @Test
    func diskStoreWithRequiredTDNMigratesToOptionalTDN() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("catalog.store")
        try createLegacyDiskStore(at: url)

        let schema = Schema([StoredFeedIngredient.self, FeedCatalogSeedState.self])
        let config = ModelConfiguration(schema: schema, url: url)
        let container = try ModelContainer(for: schema, configurations: [config])
        let reader = TestFeedCSVReader(text: Self.validCSV)
        reader.concentrates = Self.brandCSV
        try FeedCatalogSeeder(container: container, reader: reader, parser: FeedCSVParser()).seedIfNeeded()

        let context = ModelContext(container)
        let feeds = try context.fetch(FetchDescriptor<StoredFeedIngredient>())
        #expect(feeds.count == 3)
        #expect(feeds.first { $0.id == "cattle-source-001" }?.totalDigestibleNutrientsPercent == 55)
        #expect(feeds.first { $0.id == "brand-test-16" }?.totalDigestibleNutrientsPercent == nil)
    }

    private func createLegacyDiskStore(at url: URL) throws {
        let schema = Schema([LegacyFeedSchema.StoredFeedIngredient.self, FeedCatalogSeedState.self])
        let config = ModelConfiguration(schema: schema, url: url)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)
        for feed in try FeedCSVParser().parse(Self.validCSV) {
            context.insert(LegacyFeedSchema.StoredFeedIngredient(feed))
        }
        context.insert(FeedCatalogSeedState(version: 1))
        try context.save()
    }

    private static let brandCSV = """
    ID,Merek,Produsen,Varian,Jenis Hewan,Kategori,PK (%),TDN (%),Keterangan TDN
    brand-test-16,Test Brand,Test Producer,Test Variant,Sapi,Konsentrat,16,,
    """

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
    var concentrates = ""
    private(set) var concentrateReadCount = 0

    init(text: String) {
        self.text = text
    }

    func read() throws -> String {
        readCount += 1
        return text
    }

    func readConcentrates() throws -> String {
        concentrateReadCount += 1
        return concentrates
    }
}


// Reproduces the shipped catalogue schema before nullable TDN was introduced.
private enum LegacyFeedSchema {
    @Model
    final class StoredFeedIngredient {
        @Attribute(.unique) var id: String
        var name: String
        var categoryRawValue: String
        var crudeProteinPercent: Double
        var totalDigestibleNutrientsPercent: Double
        var calciumPercent: Double?
        var phosphorusPercent: Double?
        var magnesiumPercent: Double?
        var ironPPM: Double?
        var copperPPM: Double?
        var zincPPM: Double?
        var triggersGossypolWarning: Bool

        init(_ feed: FeedIngredient) {
            id = feed.id
            name = feed.name
            categoryRawValue = feed.category.rawValue
            crudeProteinPercent = feed.nutrients.crudeProteinPercent
            totalDigestibleNutrientsPercent = feed.nutrients.totalDigestibleNutrientsPercent!
            calciumPercent = feed.nutrients.calciumPercent
            phosphorusPercent = feed.nutrients.phosphorusPercent
            magnesiumPercent = feed.nutrients.magnesiumPercent
            ironPPM = feed.nutrients.ironPPM
            copperPPM = feed.nutrients.copperPPM
            zincPPM = feed.nutrients.zincPPM
            triggersGossypolWarning = feed.triggersGossypolWarning
        }
    }
}
