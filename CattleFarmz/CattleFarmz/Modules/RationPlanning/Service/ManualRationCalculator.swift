//
//  ManualRationCalculator.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 04/11/26.
//

import Foundation

struct ManualRationCalculator: RationCalculating {
    private let requirementProvider:
        (CattleRationProfile) -> NutrientContent?

    init(
        requirementProvider: @escaping
            (CattleRationProfile) -> NutrientContent?
    ) {
        self.requirementProvider = requirementProvider
    }

    func calculate(
        profile: CattleRationProfile,
        items: [RationItem]
    ) throws -> RationCalculationResult {
        try validate(profile: profile)
        
        guard !profile.usesMilkProduction
                || (profile.dailyMilkProductionLiters * 90).isFinite
        else {
            throw RationCalculationError.numericOverflow
        }

        guard items.allSatisfy({
            isNonNegativeFinite($0.kilogramsPerAnimalPerDay)
        }) else {
            throw RationCalculationError.invalidAmount
        }

        guard Set(items.map(\.id)).count == items.count else {
            throw RationCalculationError.duplicateIngredient
        }

        let activeItems = items.filter {
            $0.kilogramsPerAnimalPerDay > 0
        }

        guard !activeItems.isEmpty else {
            throw RationCalculationError.emptyRation
        }

        for item in activeItems {
            try validate(ingredient: item.ingredient)
        }

        guard let requirements = requirementProvider(profile) else {
            throw RationCalculationError.unavailableRequirements
        }

        let totalAmount = activeItems.reduce(0) {
            $0 + $1.kilogramsPerAnimalPerDay
        }

        guard totalAmount.isFinite,
              (totalAmount * Double(profile.animalCount)).isFinite
        else {
            throw RationCalculationError.numericOverflow
        }

        func average(
            _ keyPath: KeyPath<NutrientContent, Double>
        ) -> Double {
            activeItems.reduce(0) { total, item in
                let share = item.kilogramsPerAnimalPerDay / totalAmount
                let concentration = item.ingredient.nutrients[
                    keyPath: keyPath
                ]

                return total + share * concentration
            }
        }

        func optionalAverage(
            _ keyPath: KeyPath<NutrientContent, Double?>
        ) -> Double? {
            var total = 0.0

            for item in activeItems {
                guard let concentration = item.ingredient.nutrients[
                    keyPath: keyPath
                ] else {
                    return nil
                }

                let share = item.kilogramsPerAnimalPerDay / totalAmount
                total += share * concentration
            }

            return total
        }

        let nutrients = NutrientContent(
            crudeProteinPercent: average(\.crudeProteinPercent),
            totalDigestibleNutrientsPercent: average(
                \.totalDigestibleNutrientsPercent
            ),
            calciumPercent: optionalAverage(\.calciumPercent),
            phosphorusPercent: optionalAverage(\.phosphorusPercent),
            magnesiumPercent: optionalAverage(\.magnesiumPercent),
            ironPPM: optionalAverage(\.ironPPM),
            copperPPM: optionalAverage(\.copperPPM),
            zincPPM: optionalAverage(\.zincPPM)
        )

        var warnings: [String] = []

        if profile.sex == .male,
           activeItems.contains(where: {
               $0.ingredient.triggersGossypolWarning
           }) {
            warnings.append(
                """
                Gossypol warning: This ration includes cottonseed meal \
                or kapok seeds. These ingredients may contain gossypol, \
                which can affect reproduction in male cattle. \
                Consider reducing or replacing them.
                """
            )
        }

        let intakeFactor: Double
        let referenceForagePercent: Double

        switch profile.productionType {
        case .beef:
            intakeFactor = 0.022
            referenceForagePercent = 60

        case .dairy:
            intakeFactor = 0.025
            referenceForagePercent = 40
        }

        let estimatedDryMatter =
            profile.bodyWeightKilograms * intakeFactor
        
        let recommendations = RationGuidance.make(
            profile: profile,
            date: Date()
        )
        
        let result = RationCalculationResult(
            profile: profile,
            items: activeItems,
            nutrients: nutrients,
            requirements: requirements,
            warnings: warnings,
            estimatedDryMatterKilogramsPerAnimalPerDay:
                estimatedDryMatter,
            referenceForagePercent: referenceForagePercent,
            recommendations: recommendations
        )

        guard result.proteinKilogramsPerAnimalPerDay.isFinite,
              result.tdnKilogramsPerAnimalPerDay.isFinite,
              nutrients.crudeProteinPercent.isFinite,
              nutrients.totalDigestibleNutrientsPercent.isFinite,
              result.estimatedDryMatterKilogramsPerAnimalPerDay.isFinite,
              result.estimatedDryMatterKilogramsPerHerdPerDay.isFinite
        else {
            throw RationCalculationError.numericOverflow
        }

        return result
    }

    private func validate(
        profile: CattleRationProfile
    ) throws {
        guard profile.animalCount > 0,
              profile.bodyWeightKilograms.isFinite,
              profile.bodyWeightKilograms > 0,
              profile.availableStages.contains(profile.stage)
        else {
            throw RationCalculationError.invalidProfile
        }

        if profile.usesWeightGainTarget,
           !isNonNegativeFinite(
               profile.targetDailyWeightGainKilograms
           ) {
            throw RationCalculationError.invalidProfile
        }

        if profile.usesMilkProduction,
           !isNonNegativeFinite(
               profile.dailyMilkProductionLiters
           ) {
            throw RationCalculationError.invalidProfile
        }
    }

    private func validate(
        ingredient: FeedIngredient
    ) throws {
        let nutrients = ingredient.nutrients

        let percentages = [
            nutrients.crudeProteinPercent,
            nutrients.calciumPercent,
            nutrients.phosphorusPercent,
            nutrients.magnesiumPercent
        ]

        let traceMinerals = [
            nutrients.ironPPM,
            nutrients.copperPPM,
            nutrients.zincPPM
        ]

        guard !ingredient.id
            .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !ingredient.name
            .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              percentages.allSatisfy({
                  guard let value = $0 else {
                      return true
                  }

                  return isNonNegativeFinite(value) && value <= 100
              }),
              traceMinerals.allSatisfy({
                  guard let value = $0 else {
                      return true
                  }

                  return isNonNegativeFinite(value)
                      && value <= 1_000_000
              }),
              isNonNegativeFinite(
                  nutrients.totalDigestibleNutrientsPercent
              )
        else {
            throw RationCalculationError.invalidIngredient
        }
    }

    private func isNonNegativeFinite(
        _ value: Double
    ) -> Bool {
        value.isFinite && value >= 0
    }
}
