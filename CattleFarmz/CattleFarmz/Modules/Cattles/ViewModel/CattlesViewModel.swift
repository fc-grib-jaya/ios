//
//  CattlesViewModel.swift
//  CattleFarmz
//

import Foundation
import Observation

/// Backing model for the cattles screen.
@Observable
@MainActor
final class CattlesViewModel {
    private(set) var items: [Cattle] = []
    private let repository: any CattleRepository
    private let calculation: any WeightCalculation

    init(
        repository: any CattleRepository,
        calculation: any WeightCalculation
    ) {
        self.repository = repository
        self.calculation = calculation
    }
    
    func updateMeasurements(
        for cattle: Cattle,
        chestGirth: Double,
        bodyLength: Double
    ) throws {
        try repository.updateMeasurement(
            for: cattle.id,
            chestGirth: chestGirth,
            bodyLength: bodyLength
        )
    }
    
    func updateWeight(
        for cattle: Cattle,
        weight: Double
    ) throws {
        try repository.updateWeight(
            for: cattle.id,
            bodyWeight: weight
        )
    }

    func cattleWeight(for cattle: Cattle) -> Double? {
        guard let chestGirth = cattle.chestGirth else {
            return nil
        }
        
        return calculation.cattleWeight(
            chestGirth: chestGirth,
            bodyLength: cattle.bodyLength,
            breed: cattle.breed,
            gender: cattle.gender
        )
    }
    
    func carcassWeight(
        for cattle: Cattle,
        bodyWeight: Double
    ) -> Double? {
        calculation.carcassWeight(
            breed: cattle.breed,
            gender: cattle.gender,
            bodyWeight: bodyWeight
        )
    }
    
    func nonCarcassWeight(
        for cattle: Cattle,
        bodyWeight: Double,
        part: NonCarcassPart
    ) -> Double? {
        calculation.nonCarcassWeight(
            breed: cattle.breed,
            bodyWeight: bodyWeight,
            part: part
        )
    }

    func meatWeight(
        for cattle: Cattle,
        bodyWeight: Double
    ) -> Double? {
        calculation.meatWeight(
            breed: cattle.breed,
            gender: cattle.gender,
            bodyWeight: bodyWeight
        )
    }
    
    /// Loads all cattle from the repository, newest acquisitions first.
    func load() async {
        items = (try? repository.cattles()) ?? []
    }
}
