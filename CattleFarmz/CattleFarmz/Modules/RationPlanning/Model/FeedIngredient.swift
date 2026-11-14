//
//  FeedIngredient.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 04/11/26.
//

enum FeedCategory: String, Codable, CaseIterable, Identifiable {
    case forage = "Forage"
    case concentrate = "Concentrate"
    case mineral = "Mineral"

    var id: Self { self }

    var displayName: String {
        switch self {
        case .forage: "Hijauan"
        case .concentrate: "Konsentrat"
        case .mineral: "Mineral"
        }
    }
}

struct FeedIngredient: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let category: FeedCategory
    let nutrients: NutrientContent

    let triggersGossypolWarning: Bool
}
