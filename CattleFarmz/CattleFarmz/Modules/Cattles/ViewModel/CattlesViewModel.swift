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
    
    func cattleWeight(for cattle: Cattle) -> Double {
        calculation.cattleWeight(
            chestGirth: cattle.chestGirth,
            bodyLength: cattle.bodyLength,
            breed: cattle.breed,
            gender: cattle.gender
        )
    }

    /// Loads all cattle from the repository, newest acquisitions first.
    func load() async {
        items = (try? repository.cattles()) ?? []
    }
}
