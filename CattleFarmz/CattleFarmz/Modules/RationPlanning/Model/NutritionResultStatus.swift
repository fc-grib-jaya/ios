/// Status on the evaluation summary only considers Protein and TDN.
struct NutritionResultStatus {
    let proteinCoverage: Double?
    let tdnCoverage: Double?

    init(proteinCoverage: Double?, tdnCoverage: Double?) {
        self.proteinCoverage = proteinCoverage
        self.tdnCoverage = tdnCoverage
    }

    init(result: RationCalculationResult) {
        let rows = NutrientComparison.rows(for: result)
        self.init(proteinCoverage: rows[0].coverage, tdnCoverage: rows[1].coverage)
    }

    private var targets: [(name: String, coverage: Double?)] {
        [("**Protein**", proteinCoverage), ("**Energi (TDN)**", tdnCoverage)]
    }

    var complete: Bool {
        targets.allSatisfy { ($0.coverage ?? 0) >= 1 }
    }

    var belowMessage: String? {
        let names = targets.filter { ($0.coverage ?? 1) < 1 }.map(\.name)
        guard !names.isEmpty else { return nil }
        return names.joined(separator: " **dan** ") + " berada di bawah referensi minimum"
    }

    var unavailableMessage: String? {
        let names = targets.filter { $0.coverage == nil }.map(\.name)
        guard !names.isEmpty else { return nil }
        return names.joined(separator: " **dan** ") + " belum dapat dibandingkan karena data belum lengkap"
    }
}
