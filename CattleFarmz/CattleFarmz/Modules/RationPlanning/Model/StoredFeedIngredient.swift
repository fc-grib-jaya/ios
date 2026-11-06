//
//  StoredFeedIngredient.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 05/11/26.
//


import SwiftData

@Model
final class StoredFeedIngredient {
    @Attribute(.unique)
    var id: String

    var name: String
    var categoryRawValue: String

    var crudeProteinPercent: Double
    var totalDigestibleNutrientsPercent: Double

    var calciumPercent: Double?
    var phosphorusPercent: Double?
    var magnesiumPercent: Double?

    var ironPPM: Double?
    var copperPPM: Double?
    var zincPPM: Double?

    var triggersGossypolWarning: Bool

    init(ingredient: FeedIngredient) {
        id = ingredient.id
        name = ingredient.name
        categoryRawValue = ingredient.category.rawValue

        crudeProteinPercent =
            ingredient.nutrients.crudeProteinPercent

        totalDigestibleNutrientsPercent =
            ingredient.nutrients.totalDigestibleNutrientsPercent

        calciumPercent = ingredient.nutrients.calciumPercent
        phosphorusPercent = ingredient.nutrients.phosphorusPercent
        magnesiumPercent = ingredient.nutrients.magnesiumPercent

        ironPPM = ingredient.nutrients.ironPPM
        copperPPM = ingredient.nutrients.copperPPM
        zincPPM = ingredient.nutrients.zincPPM

        triggersGossypolWarning =
            ingredient.triggersGossypolWarning
    }

    func ingredient() throws -> FeedIngredient {
        guard let category = FeedCategory(
            rawValue: categoryRawValue
        ) else {
            throw MappingError.invalidCategory(categoryRawValue)
        }

        return FeedIngredient(
            id: id,
            name: name,
            category: category,
            nutrients: NutrientContent(
                crudeProteinPercent: crudeProteinPercent,
                totalDigestibleNutrientsPercent:
                    totalDigestibleNutrientsPercent,
                calciumPercent: calciumPercent,
                phosphorusPercent: phosphorusPercent,
                magnesiumPercent: magnesiumPercent,
                ironPPM: ironPPM,
                copperPPM: copperPPM,
                zincPPM: zincPPM
            ),
            triggersGossypolWarning: triggersGossypolWarning
        )
    }
}

extension StoredFeedIngredient {
    enum MappingError: Error {
        case invalidCategory(String)
    }
}