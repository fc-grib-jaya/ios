//
//  FeedIngredient.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 04/11/26.
//

enum FeedCategory: String, CaseIterable, Identifiable {
    case forage = "Forage"
    case concentrate = "Concentrate"
    case mineral = "Mineral"

    var id: Self { self }
}

struct FeedIngredient: Identifiable, Equatable {
    let id: String
    let name: String
    let category: FeedCategory
    let nutrients: NutrientContent

    let triggersGossypolWarning: Bool
}
