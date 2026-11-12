//
//  RationItem.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 04/11/26.
//

struct RationItem: Codable, Identifiable, Equatable {
    var id: String {
        ingredient.id
    }

    let ingredient: FeedIngredient
    var kilogramsPerAnimalPerDay: Double

    var proteinKilogramsPerAnimalPerDay: Double {
        kilogramsPerAnimalPerDay * (ingredient.nutrients.crudeProteinPercent / 100)
    }

    init(
        ingredient: FeedIngredient,
        kilogramsPerAnimalPerDay: Double = 0
    ) {
        self.ingredient = ingredient
        self.kilogramsPerAnimalPerDay = kilogramsPerAnimalPerDay
    }
}
