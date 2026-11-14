import Testing
import SwiftData
import Foundation
@testable import CattleFarmz

@MainActor
struct CattleMeasurementPersistenceTests {
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
        #expect(stored.chestGirth == (scanned ? 180 : nil))
        #expect(stored.bodyLength == (scanned ? 150 : nil))
        #expect(model.weightBreakdown(for: stored).bodyWeight == 450)
    }
}
