//
//  RationCalculationResult.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 04/11/26.
//

struct RationCalculationResult {
    let profile: CattleRationProfile
    let items: [RationItem]

    let nutrients: NutrientContent
    let requirements: NutrientContent

    let warnings: [String]
    
    let estimatedDryMatterKilogramsPerAnimalPerDay: Double
    let referenceForagePercent: Double
    
    let recommendations: [String]

    var estimatedDryMatterKilogramsPerHerdPerDay: Double {
        estimatedDryMatterKilogramsPerAnimalPerDay
            * Double(profile.animalCount)
    }

    var referenceConcentratePercent: Double {
        100 - referenceForagePercent
    }

    var kilogramsPerAnimalPerDay: Double {
        items.reduce(0) {
            $0 + $1.kilogramsPerAnimalPerDay
        }
    }

    var kilogramsPerHerdPerDay: Double {
        kilogramsPerAnimalPerDay * Double(profile.animalCount)
    }

    var proteinKilogramsPerAnimalPerDay: Double {
        items.reduce(0) {
            $0 + $1.kilogramsPerAnimalPerDay
                * ($1.ingredient.nutrients.crudeProteinPercent / 100)
        }
    }

    var tdnKilogramsPerAnimalPerDay: Double {
        items.reduce(0) {
            $0 + $1.kilogramsPerAnimalPerDay
                * ($1.ingredient.nutrients.totalDigestibleNutrientsPercent / 100)
        }
    }

    func sharePercent(for category: FeedCategory) -> Double {
        let total = kilogramsPerAnimalPerDay

        guard total > 0 else {
            return 0
        }

        let categoryAmount = items
            .filter { $0.ingredient.category == category }
            .reduce(0) {
                $0 + $1.kilogramsPerAnimalPerDay
            }

        return categoryAmount / total * 100
    }
}
