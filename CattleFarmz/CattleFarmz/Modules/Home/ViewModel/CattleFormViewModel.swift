//
//  CattleFormViewModel.swift
//  CattleFarmz
//

import Foundation
import Observation

/// Backing model for the add-cattle form.
@Observable
@MainActor
final class CattleFormViewModel {
    /// Last scan measurement, kept until breed and gender are chosen so the
    /// estimated weight can be recalculated.
    private(set) var scanResult: ScanResult?

    private let calculation: any WeightCalculation

    init(calculation: any WeightCalculation) {
        self.calculation = calculation
    }

    /// Stores the result of one finished scan session.
    func storeScanResult(_ result: ScanResult?) {
        scanResult = result
    }

    /// Estimated body weight from the stored scan, or `nil` while the scan,
    /// breed, or gender is still missing.
    func estimatedWeight(breed: CattleBreed?, gender: CattleGender?) -> Double? {
        guard let scanResult,
              let girth = scanResult.girth,
              let breed,
              let gender else {
            return nil
        }

        return calculation.cattleWeight(
            chestGirth: girth,
            bodyLength: scanResult.lengthCM,
            breed: breed,
            gender: gender
        )
    }
}
