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

    init(repository: any CattleRepository) {
        self.repository = repository
    }

    /// Loads all cattle from the repository, newest acquisitions first.
    func load() async {
        items = (try? repository.cattles()) ?? []
    }
}
