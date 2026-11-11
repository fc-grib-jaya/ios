#if DEBUG
// Shared fixtures for the evaluation component previews.
enum RationEvaluationPreviewData {
    static var result: RationCalculationResult {
        var profile = CattleRationProfile()
        profile.bodyWeightKilograms = 544.5
        profile.targetDailyWeightGainKilograms = 1.2

        let nutrients = NutrientContent(
            crudeProteinPercent: 22.92, totalDigestibleNutrientsPercent: 63,
            calciumPercent: 0.42, phosphorusPercent: 0.42, magnesiumPercent: 0.24,
            ironPPM: 198, copperPPM: 12, zincPPM: 44
        )
        let requirements = NutrientContent(
            crudeProteinPercent: 10.5, totalDigestibleNutrientsPercent: 60,
            calciumPercent: 0.35, phosphorusPercent: 0.25, magnesiumPercent: 0.1,
            ironPPM: 50, copperPPM: 10, zincPPM: 40
        )
        let items = [
            RationItem(
                ingredient: FeedIngredient(
                    id: "preview-grass", name: "Rumput Gajah", category: .forage,
                    nutrients: nutrients, triggersGossypolWarning: false
                ),
                kilogramsPerAnimalPerDay: 20
            ),
            RationItem(
                ingredient: FeedIngredient(
                    id: "preview-soy", name: "Bungkil Kedelai", category: .concentrate,
                    nutrients: nutrients, triggersGossypolWarning: false
                ),
                kilogramsPerAnimalPerDay: 1
            ),
            RationItem(
                ingredient: FeedIngredient(
                    id: "preview-tofu", name: "Ampas Tahu", category: .concentrate,
                    nutrients: nutrients, triggersGossypolWarning: false
                ),
                kilogramsPerAnimalPerDay: 5
            )
        ]
        return RationCalculationResult(
            profile: profile,
            items: items,
            nutrients: nutrients,
            requirements: requirements,
            warnings: [],
            estimatedDryMatterKilogramsPerAnimalPerDay: 11.979,
            referenceForagePercent: 60,
            recommendations: []
        )
    }
}
#endif
