struct NutrientComparison: Identifiable {
    let name: String
    let actual: Double?
    let minimum: Double?
    let unit: String
    var id: String { name }
    var coverage: Double? {
        guard let actual, let minimum, minimum > 0 else { return nil }
        return actual / minimum
    }

    static func rows(for result: RationCalculationResult) -> [Self] {
        let a = result.nutrients
        let m = result.requirements
        return [
            Self(name: "Protein kasar", actual: a.crudeProteinPercent, minimum: m.crudeProteinPercent, unit: "%"),
            Self(name: "TDN", actual: a.totalDigestibleNutrientsPercent, minimum: m.totalDigestibleNutrientsPercent, unit: "%"),
            Self(name: "Kalsium", actual: a.calciumPercent, minimum: m.calciumPercent, unit: "%"),
            Self(name: "Fosfor", actual: a.phosphorusPercent, minimum: m.phosphorusPercent, unit: "%"),
            Self(name: "Magnesium", actual: a.magnesiumPercent, minimum: m.magnesiumPercent, unit: "%"),
            Self(name: "Besi", actual: a.ironPPM, minimum: m.ironPPM, unit: "ppm"),
            Self(name: "Copper", actual: a.copperPPM, minimum: m.copperPPM, unit: "ppm"),
            Self(name: "Zinc", actual: a.zincPPM, minimum: m.zincPPM, unit: "ppm")
        ]
    }
}
