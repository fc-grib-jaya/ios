import Testing
@testable import CattleFarmz

struct NutritionResultStatusTests {
    @Test func namesTheDeficientTargetsWithoutCounts() {
        let protein = NutritionResultStatus(proteinCoverage: 0.9, tdnCoverage: 1)
        let tdn = NutritionResultStatus(proteinCoverage: 1.2, tdnCoverage: 0.9)
        let both = NutritionResultStatus(proteinCoverage: 0.9, tdnCoverage: 0.8)
        #expect(protein.belowMessage == "Protein berada di bawah nilai minimum referensi.")
        #expect(tdn.belowMessage == "TDN berada di bawah nilai minimum referensi.")
        #expect(both.belowMessage == "Protein dan TDN berada di bawah nilai minimum referensi.")
        #expect(!protein.complete && !tdn.complete && !both.complete)
    }

    @Test func exactMinimumIsCompleteAndMissingDataIsNot() {
        let complete = NutritionResultStatus(proteinCoverage: 1, tdnCoverage: 1)
        #expect(complete.complete)
        #expect(complete.belowMessage == nil)
        #expect(complete.unavailableMessage == nil)
        let unknown = NutritionResultStatus(proteinCoverage: 1.2, tdnCoverage: nil)
        #expect(!unknown.complete)
        #expect(unknown.belowMessage == nil)
        #expect(unknown.unavailableMessage == "TDN belum dapat dibandingkan karena data belum lengkap.")
    }

    @Test @MainActor func mineralDeficienciesDoNotAffectTheSummary() {
        let base = RationEvaluationPreviewData.result
        let nutrients = NutrientContent(crudeProteinPercent: base.requirements.crudeProteinPercent,
                                        totalDigestibleNutrientsPercent: base.requirements.totalDigestibleNutrientsPercent,
                                        calciumPercent: 0, phosphorusPercent: 0, magnesiumPercent: nil,
                                        ironPPM: 0, copperPPM: nil, zincPPM: 0)
        let result = RationCalculationResult(profile: base.profile, items: base.items,
                                             nutrients: nutrients, requirements: base.requirements,
                                             warnings: [], estimatedDryMatterKilogramsPerAnimalPerDay: 0,
                                             referenceForagePercent: 60, recommendations: [])
        #expect(NutritionResultStatus(result: result).complete)
    }
}
