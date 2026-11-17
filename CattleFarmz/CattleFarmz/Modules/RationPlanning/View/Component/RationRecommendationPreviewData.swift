#if DEBUG
import Foundation

@MainActor
enum RationRecommendationPreviewData {
    static func viewModel() -> RationRecommendationViewModel {
        let before = RationEvaluationPreviewData.result
        let calculator = ManualRationCalculator { _ in before.requirements }
        let engine = RationRecommendationEngine(calculator: calculator)
        let source = before.items[0].ingredient
        let nutrients = NutrientContent(
            crudeProteinPercent: 14, totalDigestibleNutrientsPercent: 61,
            calciumPercent: 0.5, phosphorusPercent: 0.3, magnesiumPercent: 0.2,
            ironPPM: 100, copperPPM: 12, zincPPM: 40
        )
        let target = FeedIngredient(id: "preview-odot", name: "Rumput odot", category: source.category,
                                    nutrients: nutrients, triggersGossypolWarning: false)
        let proposal = RationRecommendation(removedIngredient: source, addedIngredient: target,
                                            replacedKilograms: 2, before: before, after: before)
        return RationRecommendationViewModel(recommendation: proposal, alternatives: [proposal], engine: engine)
    }
}
#endif
