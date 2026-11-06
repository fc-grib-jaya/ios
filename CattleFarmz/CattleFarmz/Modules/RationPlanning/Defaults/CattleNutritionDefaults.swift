// Cattle reference requirements from default_nutrition_requirements() in the upstream Python source.
// Values are reference data, not independently validated feeding recommendations.
enum CattleNutritionDefaults {
    static func requirements(
        for productionType: CattleProductionType,
        stage: CattleProductionStage
    ) -> NutrientContent? {
        switch (productionType, stage) {
        case (.beef, .calf): return NutrientContent(crudeProteinPercent: 18.0, totalDigestibleNutrientsPercent: 70.0, calciumPercent: 0.7, phosphorusPercent: 0.45, magnesiumPercent: 0.1, ironPPM: 50.0, copperPPM: 10.0, zincPPM: 40.0)
        case (.beef, .growing): return NutrientContent(crudeProteinPercent: 12.5, totalDigestibleNutrientsPercent: 65.0, calciumPercent: 0.55, phosphorusPercent: 0.35, magnesiumPercent: 0.1, ironPPM: 50.0, copperPPM: 10.0, zincPPM: 40.0)
        case (.beef, .adult): return NutrientContent(crudeProteinPercent: 10.5, totalDigestibleNutrientsPercent: 60.0, calciumPercent: 0.35, phosphorusPercent: 0.25, magnesiumPercent: 0.1, ironPPM: 50.0, copperPPM: 10.0, zincPPM: 40.0)
        case (.beef, .pregnant): return NutrientContent(crudeProteinPercent: 11.0, totalDigestibleNutrientsPercent: 65.0, calciumPercent: 0.45, phosphorusPercent: 0.3, magnesiumPercent: 0.12, ironPPM: 50.0, copperPPM: 10.0, zincPPM: 40.0)
        case (.beef, .fattening): return NutrientContent(crudeProteinPercent: 14.0, totalDigestibleNutrientsPercent: 70.0, calciumPercent: 0.5, phosphorusPercent: 0.3, magnesiumPercent: 0.1, ironPPM: 50.0, copperPPM: 10.0, zincPPM: 40.0)
        case (.dairy, .calf): return NutrientContent(crudeProteinPercent: 18.0, totalDigestibleNutrientsPercent: 72.0, calciumPercent: 0.7, phosphorusPercent: 0.45, magnesiumPercent: 0.1, ironPPM: 50.0, copperPPM: 10.0, zincPPM: 40.0)
        case (.dairy, .heifer): return NutrientContent(crudeProteinPercent: 15.0, totalDigestibleNutrientsPercent: 65.0, calciumPercent: 0.6, phosphorusPercent: 0.4, magnesiumPercent: 0.1, ironPPM: 50.0, copperPPM: 10.0, zincPPM: 40.0)
        case (.dairy, .pregnantHeifer): return NutrientContent(crudeProteinPercent: 12.0, totalDigestibleNutrientsPercent: 65.0, calciumPercent: 0.6, phosphorusPercent: 0.4, magnesiumPercent: 0.16, ironPPM: 50.0, copperPPM: 10.0, zincPPM: 40.0)
        case (.dairy, .lowProductionLactation): return NutrientContent(crudeProteinPercent: 14.0, totalDigestibleNutrientsPercent: 65.0, calciumPercent: 0.6, phosphorusPercent: 0.4, magnesiumPercent: 0.2, ironPPM: 50.0, copperPPM: 10.0, zincPPM: 40.0)
        case (.dairy, .highProductionLactation): return NutrientContent(crudeProteinPercent: 16.0, totalDigestibleNutrientsPercent: 75.0, calciumPercent: 0.8, phosphorusPercent: 0.5, magnesiumPercent: 0.25, ironPPM: 50.0, copperPPM: 10.0, zincPPM: 40.0)
        case (.dairy, .dry): return NutrientContent(crudeProteinPercent: 12.0, totalDigestibleNutrientsPercent: 60.0, calciumPercent: 0.45, phosphorusPercent: 0.35, magnesiumPercent: 0.16, ironPPM: 50.0, copperPPM: 10.0, zincPPM: 40.0)
        default: return nil
        }
    }
}
