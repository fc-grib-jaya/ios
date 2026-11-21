import Testing
import SwiftData
import Foundation
@testable import CattleFarmz

@MainActor
struct CattleMeasurementPersistenceTests {
    @Test
    func latestMeasurementDrivesDisplaysAndSurvivesRefetch() throws {
        let container = try PersistenceController.makeContainer(for: [Cattle.self], inMemory: true)
        let context = container.mainContext
        let repository = SwiftDataCattleRepository(context: context)
        let acquired = Date.now.addingTimeInterval(-86_400 * 10)
        try repository.add(
            name: "Progress", dateAcquired: acquired, breed: .bali, gender: .male,
            recordedAge: 24, chestGirth: nil, bodyLength: nil, bodyWeight: 450,
            cattleImage: nil, notes: nil
        )
        let cattle = try #require(repository.cattles().first)
        let progress = CattleWeightProgressViewModel(cattle: cattle, modelContext: context)
        let displays = CattlesViewModel(repository: repository, calculation: WeightCalculator(), toast: ToastManager())
        progress.addProgress(weight: 500, measuredAt: acquired.addingTimeInterval(200))
        progress.addProgress(weight: 470, measuredAt: acquired.addingTimeInterval(100))
        #expect(progress.errorMessage == nil)
        #expect(progress.currentWeight == 500)
        #expect(displays.cattleWeight(for: cattle) == 500)
        #expect(displays.weightBreakdown(for: cattle).bodyWeight == 500)
        #expect(progress.totalWeightGain == 50)
        let freshContext = ModelContext(container)
        let stored = try #require(freshContext.fetch(FetchDescriptor<Cattle>()).first)
        #expect(stored.weightProgress.count == 3)
        #expect(CattleWeightProgressViewModel.currentWeight(for: stored) == 500)
        progress.removeProgress(try #require(progress.progress.last))
        #expect(displays.cattleWeight(for: cattle) == 470)
        progress.addProgress(weight: .nan)
        #expect(progress.errorMessage != nil)
        #expect(cattle.weightProgress.count == 2)
    }

    @Test(arguments: [false, true])
    func repositoryWeightUpdatesCreateHistory(mock: Bool) throws {
        let container = try PersistenceController.makeContainer(for: [Cattle.self], inMemory: true)
        let repository: any CattleRepository = mock
            ? MockCattleRepository(items: [])
            : SwiftDataCattleRepository(context: container.mainContext)
        try repository.add(
            name: "Updates", dateAcquired: .now.addingTimeInterval(-86_400),
            breed: .bali, gender: .male, recordedAge: 24,
            chestGirth: nil, bodyLength: nil, bodyWeight: 450, cattleImage: nil, notes: nil
        )
        let cattle = try #require(repository.cattles().first)
        try repository.updateWeight(for: cattle.id, bodyWeight: 510)
        #expect(cattle.weightProgress.count == 2)
        #expect(CattleWeightProgressViewModel.currentWeight(for: cattle) == 510)
        try repository.updateMeasurement(for: cattle.id, chestGirth: 180, bodyLength: 150)
        #expect(cattle.weightProgress.count == 3)
        let expected = try #require(WeightCalculator().cattleWeight(
            chestGirth: 180, bodyLength: 150, breed: .bali, gender: .male
        ))
        let actual = try #require(CattleWeightProgressViewModel.currentWeight(for: cattle))
        #expect(abs(actual - expected) < 0.005)
        try repository.update(
            for: cattle.id, name: "Renamed", dateAcquired: cattle.dateAcquired,
            breed: cattle.breed, gender: cattle.gender, recordedAge: cattle.recordedAge,
            chestGirth: cattle.chestGirth, bodyLength: cattle.bodyLength,
            bodyWeight: actual, cattleImage: nil, notes: nil
        )
        #expect(cattle.weightProgress.count == 3)
        #expect(cattle.bodyWeight == 450)
    }

    @Test(arguments: [false, true])
    func editingWeightOverwritesOnlySelectedCattlesLatestRecord(mock: Bool) throws {
        let container = try PersistenceController.makeContainer(for: [Cattle.self], inMemory: true)
        let repository: any CattleRepository = mock
            ? MockCattleRepository(items: [])
            : SwiftDataCattleRepository(context: container.mainContext)
        let acquired = Date.now.addingTimeInterval(-86_400)
        for name in ["Selected", "Other"] {
            try repository.add(
                name: name, dateAcquired: acquired, breed: .bali, gender: .male,
                recordedAge: 24, chestGirth: nil, bodyLength: nil, bodyWeight: 450,
                cattleImage: nil, notes: "Keep"
            )
        }
        let cattle = try #require(repository.cattles().first { $0.name == "Selected" })
        let other = try #require(repository.cattles().first { $0.name == "Other" })
        // Insert out of date order to ensure the latest is selected by measurement date.
        try CattleWeightProgressViewModel.recordProgress(
            for: cattle, weight: 510, measuredAt: acquired.addingTimeInterval(200),
            chestGirth: 180, bodyLength: 150
        )
        try CattleWeightProgressViewModel.recordProgress(
            for: cattle, weight: 480, measuredAt: acquired.addingTimeInterval(100)
        )
        let latest = try #require(CattleWeightProgressViewModel.latestProgress(for: cattle))
        let latestID = latest.id
        let latestDate = latest.measuredAt
        let originalIDs = Set(cattle.weightProgress.map(\.id))
        let otherID = try #require(other.weightProgress.first).id

        for _ in 0..<2 {
            try repository.update(
                for: cattle.id, name: cattle.name, dateAcquired: cattle.dateAcquired,
                breed: cattle.breed, gender: cattle.gender, recordedAge: cattle.recordedAge,
                chestGirth: cattle.chestGirth, bodyLength: cattle.bodyLength,
                bodyWeight: 525.126, cattleImage: cattle.cattleImage, notes: cattle.notes
            )
        }

        let storedCattle: Cattle
        let storedOther: Cattle
        if mock {
            storedCattle = cattle
            storedOther = other
        } else {
            let records = try ModelContext(container).fetch(FetchDescriptor<Cattle>())
            storedCattle = try #require(records.first { $0.id == cattle.id })
            storedOther = try #require(records.first { $0.id == other.id })
        }
        let storedLatest = try #require(CattleWeightProgressViewModel.latestProgress(for: storedCattle))
        #expect(Set(storedCattle.weightProgress.map(\.id)) == originalIDs)
        #expect(storedCattle.weightProgress.count == 3)
        #expect(storedLatest.id == latestID)
        #expect(storedLatest.measuredAt == latestDate)
        #expect(storedLatest.weight == 525.13)
        #expect(storedLatest.chestGirth == 180)
        #expect(storedLatest.bodyLength == 150)
        #expect(CattleWeightProgressViewModel.sortedProgress(storedCattle.weightProgress).map(\.weight) == [450, 480, 525.13])
        #expect(storedCattle.notes == "Keep")
        #expect(storedCattle.bodyWeight == 450)
        #expect(storedOther.weightProgress.count == 1)
        #expect(storedOther.weightProgress.first?.id == otherID)
        #expect(storedOther.weightProgress.first?.weight == 450)
    }

    @Test
    func editingLegacyWeightDoesNotCreateHistory() throws {
        let cattle = Cattle(
            name: "Legacy", dateAcquired: .now, breed: .bali, gender: .male,
            recordedAge: 24, bodyWeight: 450
        )
        try CattleWeightProgressViewModel.recordEditedProgress(
            for: cattle, bodyWeight: 500, chestGirth: nil, bodyLength: nil,
            breed: cattle.breed, gender: cattle.gender
        )
        #expect(cattle.weightProgress.isEmpty)
        #expect(CattleWeightProgressViewModel.currentWeight(for: cattle) == 500)
    }

    @Test(arguments: [false, true])
    func savedMeasurementsReachDetailAfterRefetch(scanned: Bool) throws {
        let container = try PersistenceController.makeContainer(for: [Cattle.self], inMemory: true)
        let repository = SwiftDataCattleRepository(context: container.mainContext)
        let model = CattlesViewModel(repository: repository, calculation: WeightCalculator(), toast: ToastManager())
        try model.addCattle(
            name: "Test", dateAcquired: .now, breed: .bali, gender: .male,
            recordedAge: 24, chestGirth: scanned ? 180 : nil,
            bodyLength: scanned ? 150 : nil, bodyWeight: 450,
            cattleImage: nil, notes: nil
        )
        let context = ModelContext(container)
        let stored = try #require(context.fetch(FetchDescriptor<Cattle>()).first)
        #expect(stored.bodyWeight == 450)
        let initial = try #require(stored.weightProgress.first)
        #expect(stored.weightProgress.count == 1)
        #expect(initial.weight == 450)
        #expect(initial.measuredAt == stored.dateAcquired)
        #expect(initial.cattle?.id == stored.id)
        #expect(stored.chestGirth == (scanned ? 180 : nil))
        #expect(stored.bodyLength == (scanned ? 150 : nil))
        #expect(model.weightBreakdown(for: stored).bodyWeight == 450)
    }
}
