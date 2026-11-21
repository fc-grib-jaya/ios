//
//  CattleWeightProgressViewModel.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 21/11/26.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class CattleWeightProgressViewModel {
    let cattle: Cattle

    private let modelContext: ModelContext

    var errorMessage: String?

    init(cattle: Cattle, modelContext: ModelContext) {
        self.cattle = cattle
        self.modelContext = modelContext
    }

    var progress: [CattleWeightProgress] {
        Self.sortedProgress(cattle.weightProgress)
    }
    
    var progressComparison: String {
        guard progress.count >= 2 else {
            return "Belum ada perbandingan"
        }

        let latest = progress[progress.count - 1].weight
        let previous = progress[progress.count - 2].weight

        if latest > previous {
            return "naik"
        } else if latest < previous {
            return "turun"
        }

        return "tetap"
    }
    
    var progressDifference: Int {
        guard progress.count >= 2 else { return 0 }

        let latest = progress[progress.count - 1].weight
        let previous = progress[progress.count - 2].weight

        return Int(abs(latest - previous).rounded())
    }

    var lastMeasuredAt: Date {
        progress.last?.measuredAt ?? cattle.dateAcquired
    }

    var secondLastMeasuredAt: Date? {
        guard progress.count >= 2 else { return nil }

        return progress[progress.count - 2].measuredAt
    }
    
    var currentWeight: Double? {
        Self.currentWeight(for: cattle)
    }

    /// Read the relationship directly so every observing view follows saved measurements.
    static func currentWeight(
        for cattle: Cattle,
        calculation: any WeightCalculation = WeightCalculator()
    ) -> Double? {
        latestProgress(for: cattle)?.weight ?? initialWeight(for: cattle, calculation: calculation)
    }

    static func latestProgress(for cattle: Cattle) -> CattleWeightProgress? {
        cattle.weightProgress.max(by: precedes)
    }

    static func sortedProgress(_ records: [CattleWeightProgress]) -> [CattleWeightProgress] {
        records.sorted(by: precedes)
    }

    private static func precedes(_ first: CattleWeightProgress, _ second: CattleWeightProgress) -> Bool {
        if first.measuredAt == second.measuredAt {
            return first.id.uuidString < second.id.uuidString
        }
        return first.measuredAt < second.measuredAt
    }

    /// Legacy cattle may have dimensions but no stored weight or history.
    static func initialWeight(
        for cattle: Cattle,
        calculation: any WeightCalculation = WeightCalculator()
    ) -> Double? {
        if let weight = cattle.bodyWeight { return weight }
        guard let girth = cattle.chestGirth else { return nil }
        return calculation.cattleWeight(
            chestGirth: girth,
            bodyLength: cattle.bodyLength,
            breed: cattle.breed,
            gender: cattle.gender
        )
    }

    /// The caller saves the cattle and its first measurement in one transaction.
    static func createInitialProgress(for cattle: Cattle) {
        guard cattle.weightProgress.isEmpty,
            let weight = initialWeight(for: cattle),
            weight.isFinite, weight > 0
        else { return }
        let entry = CattleWeightProgress(
            weight: weight,
            measuredAt: cattle.dateAcquired,
            chestGirth: cattle.chestGirth,
            bodyLength: cattle.bodyLength
        )
        cattle.weightProgress.append(entry)
    }

    /// Editing corrects the latest measurement without adding or reordering history.
    static func recordEditedProgress(
        for cattle: Cattle,
        bodyWeight: Double?,
        chestGirth: Double?,
        bodyLength: Double?,
        breed: CattleBreed,
        gender: CattleGender
    ) throws {
        let weight = bodyWeight ?? chestGirth.flatMap {
            WeightCalculator().cattleWeight(
                chestGirth: $0, bodyLength: bodyLength, breed: breed, gender: gender
            )
        }
        guard let weight, weight != currentWeight(for: cattle) else { return }
        guard weight.isFinite, weight > 0, weight <= 9_999 else {
            throw CattleRepositoryError.invalidWeight
        }

        let roundedWeight = (weight * 100).rounded() / 100
        if let latest = latestProgress(for: cattle) {
            // Keep the record's identity, measurement date, and measurement metadata.
            latest.weight = roundedWeight
        } else {
            // Legacy cattle without history retain their weight directly on the cattle.
            cattle.bodyWeight = roundedWeight
        }
    }

    static func recordMeasurement(for cattle: Cattle, chestGirth: Double, bodyLength: Double) throws {
        guard let weight = WeightCalculator().cattleWeight(
            chestGirth: chestGirth,
            bodyLength: bodyLength,
            breed: cattle.breed,
            gender: cattle.gender
        ) else {
            throw CattleRepositoryError.invalidMeasurement
        }
        try recordProgress(
            for: cattle, weight: weight, chestGirth: chestGirth, bodyLength: bodyLength
        )
    }

    static func recordProgress(
        for cattle: Cattle,
        weight: Double,
        measuredAt: Date = .now,
        chestGirth: Double? = nil,
        bodyLength: Double? = nil
    ) throws {
        guard weight.isFinite, weight > 0, weight <= 9_999 else {
            throw CattleRepositoryError.invalidWeight
        }
        createInitialProgress(for: cattle)
        let entry = CattleWeightProgress(
            weight: (weight * 100).rounded() / 100,
            measuredAt: measuredAt,
            chestGirth: chestGirth,
            bodyLength: bodyLength
        )
        cattle.weightProgress.append(entry)
    }

    var totalWeightGain: Double? {
        guard
            let first = progress.first,
            let last = progress.last,
            progress.count >= 2
        else {
            return nil
        }

        return last.weight - first.weight
    }

    func addProgress(
        weight: Double,
        measuredAt: Date = .now,
        chestGirth: Double? = nil,
        bodyLength: Double? = nil
    ) {
        guard weight.isFinite, weight > 0, weight <= 9_999 else {
            errorMessage = "Bobot harus lebih dari 0 dan maksimal 9.999 kg."
            return
        }

        errorMessage = nil

        do {
            try Self.recordProgress(
                for: cattle,
                weight: weight,
                measuredAt: measuredAt,
                chestGirth: chestGirth,
                bodyLength: bodyLength
            )
            saveChanges()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeProgress(_ entry: CattleWeightProgress) {
        guard cattle.weightProgress.contains(where: { $0.id == entry.id }) else { return }
        errorMessage = nil

        cattle.weightProgress.removeAll {
            $0.id == entry.id
        }

        modelContext.delete(entry)

        saveChanges()
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            // Mengembalikan perubahan yang belum berhasil disimpan.
            modelContext.rollback()
            errorMessage = "Gagal menyimpan perubahan: \(error.localizedDescription)"
        }
    }
}
