enum RationRecommendationTarget: String, CaseIterable, Identifiable {
    case protein
    case tdn

    var id: Self { self }
    var comparisonIndex: Int { self == .protein ? 0 : 1 }
    var displayName: String { self == .protein ? "Protein" : "Energi (TDN)" }

    func value(in nutrients: NutrientContent) -> Double? {
        self == .protein ? nutrients.crudeProteinPercent : nutrients.totalDigestibleNutrientsPercent
    }
}

struct RationRecommendationGroup: Identifiable {
    let target: RationRecommendationTarget
    let alternatives: [RationRecommendation]
    var id: RationRecommendationTarget { target }
    var best: RationRecommendation? { alternatives.first }
}
