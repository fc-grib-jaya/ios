struct RationRecommendation: Identifiable {
    let removedIngredient: FeedIngredient
    let addedIngredient: FeedIngredient
    let replacedKilograms: Double
    let before: RationCalculationResult
    let after: RationCalculationResult
    var target: RationRecommendationTarget? = nil

    var focusTarget: RationRecommendationTarget {
        target ?? ((NutrientComparison.rows(for: before)[1].coverage ?? 0) < 1 ? .tdn : .protein)
    }

    var id: String { removedIngredient.id + "→" + addedIngredient.id }

    var meetsTargets: Bool {
        let protein = after.requirements.crudeProteinPercent
        guard protein > 0,
              let tdn = after.nutrients.totalDigestibleNutrientsPercent,
              let requiredTDN = after.requirements.totalDigestibleNutrientsPercent,
              requiredTDN > 0 else { return false }
        return after.nutrients.crudeProteinPercent >= protein - 1e-9
            && tdn >= requiredTDN - 1e-9
    }
}
