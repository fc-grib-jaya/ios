//
//  RationItem.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 04/11/26.
//

struct RationItem: Identifiable, Equatable {
    var id: String {
        ingredient.id
    }

    let ingredient: FeedIngredient
    var kilogramsPerAnimalPerDay: Double

    init(
        ingredient: FeedIngredient,
        kilogramsPerAnimalPerDay: Double = 0
    ) {
        self.ingredient = ingredient
        self.kilogramsPerAnimalPerDay = kilogramsPerAnimalPerDay
    }
}
