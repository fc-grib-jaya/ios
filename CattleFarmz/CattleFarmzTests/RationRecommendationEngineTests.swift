import Testing
@testable import CattleFarmz

@MainActor
struct RationRecommendationEngineTests {
    private func feed(
        _ id: String, protein: Double, tdn: Double?, category: FeedCategory = .forage,
        calcium: Double? = 0.5, warning: Bool = false
    ) -> FeedIngredient {
        FeedIngredient(
            id: id, name: id, category: category,
            nutrients: NutrientContent(
                crudeProteinPercent: protein, totalDigestibleNutrientsPercent: tdn,
                calciumPercent: calcium, phosphorusPercent: nil, magnesiumPercent: nil,
                ironPPM: nil, copperPPM: nil, zincPPM: nil
            ), triggersGossypolWarning: warning
        )
    }

    private var calculator: ManualRationCalculator {
        ManualRationCalculator { _ in
            NutrientContent(
                crudeProteinPercent: 10.5, totalDigestibleNutrientsPercent: 60,
                calciumPercent: 0.35, phosphorusPercent: nil, magnesiumPercent: nil,
                ironPPM: nil, copperPPM: nil, zincPPM: nil
            )
        }
    }

    private func result(_ items: [RationItem]) throws -> RationCalculationResult {
        try calculator.calculate(profile: CattleRationProfile(), items: items)
    }

    @Test func findsSmallestReplacementMeetingBothTargets() throws {
        let original = feed("grass", protein: 8, tdn: 50)
        let replacement = feed("alternative", protein: 18, tdn: 75)
        let before = try result([RationItem(ingredient: original, kilogramsPerAnimalPerDay: 10)])
        let options = try RationRecommendationEngine(calculator: calculator)
            .recommend(for: before, catalog: [original, replacement])
        let first = try #require(options.first)
        #expect(options.count == 1)
        #expect(first.meetsTargets)
        #expect(abs(first.replacedKilograms - 4) < 1e-8)
        #expect(abs(first.after.kilogramsPerAnimalPerDay - 10) < 1e-8)
        #expect(abs((first.after.nutrients.totalDigestibleNutrientsPercent ?? 0) - 60) < 1e-8)
        #expect(before.items[0].kilogramsPerAnimalPerDay == 10)
    }

    @Test func offersFullReplacementAsPartialImprovement() throws {
        let original = feed("grass", protein: 8, tdn: 50)
        let replacement = feed("better-grass", protein: 9, tdn: 55)
        let before = try result([RationItem(ingredient: original, kilogramsPerAnimalPerDay: 10)])
        let first = try #require(RationRecommendationEngine(calculator: calculator)
            .recommend(for: before, catalog: [replacement]).first)
        #expect(!first.meetsTargets)
        #expect(first.replacedKilograms == 10)
        #expect(first.after.items.count == 1)
        #expect(first.after.items.first?.ingredient == replacement)
    }

    @Test func neverTradesAMetTargetForANewDeficiency() throws {
        let original = feed("grass", protein: 20, tdn: 50)
        let replacement = feed("weak-protein", protein: 1, tdn: 51)
        let before = try result([RationItem(ingredient: original, kilogramsPerAnimalPerDay: 10)])
        let first = try #require(RationRecommendationEngine(calculator: calculator)
            .recommend(for: before, catalog: [replacement]).first)
        #expect(first.after.nutrients.crudeProteinPercent >= 10.5 - 1e-9)
        #expect((first.after.nutrients.totalDigestibleNutrientsPercent ?? 0) > 50)
        #expect(first.replacedKilograms < 10)
    }

    @Test func rejectsChangesThatReduceAlreadyLowTDNAndDifferentCategories() throws {
        let original = feed("grass", protein: 8, tdn: 50)
        let before = try result([RationItem(ingredient: original, kilogramsPerAnimalPerDay: 10)])
        let options = try RationRecommendationEngine(calculator: calculator).recommend(
            for: before, catalog: [
                feed("unknown", protein: 30, tdn: nil),
                feed("concentrate", protein: 30, tdn: 80, category: .concentrate)
            ]
        )
        #expect(options.isEmpty)
    }

    @Test func canUseKnownProteinWhenCandidateTDNIsMissing() throws {
        let original = feed("high-energy-grass", protein: 8, tdn: 80)
        let proteinSource = feed("protein-without-tdn", protein: 30, tdn: nil)
        let before = try result([RationItem(ingredient: original, kilogramsPerAnimalPerDay: 10)])
        let first = try #require(RationRecommendationEngine(calculator: calculator)
            .recommend(for: before, catalog: [proteinSource]).first)
        #expect(first.meetsTargets)
        #expect(abs(first.after.nutrients.crudeProteinPercent - 10.5) < 1e-8)
        #expect((first.after.nutrients.totalDigestibleNutrientsPercent ?? 0) >= 60)
    }

    @Test func substitutesUsingZeroForMissingNutrients() throws {
        let original = feed("unknown-grass", protein: 8, tdn: nil)
        let replacement = feed("known-grass", protein: 18, tdn: 75, calcium: nil)
        let before = try result([RationItem(ingredient: original, kilogramsPerAnimalPerDay: 10)])
        let first = try #require(RationRecommendationEngine(calculator: calculator)
            .recommend(for: before, catalog: [replacement]).first)
        #expect(first.meetsTargets)
        #expect(abs(first.replacedKilograms - 8) < 1e-8)
        #expect(first.before.nutrients.calciumPercent == 0.5)
        #expect(abs((first.after.nutrients.calciumPercent ?? 0) - 0.1) < 1e-8)
    }

    @Test func mergesAnAlreadySelectedIngredientAndKeepsCategoryMass() throws {
        let original = feed("grass", protein: 8, tdn: 50)
        let replacement = feed("alternative", protein: 18, tdn: 75)
        let concentrate = feed("concentrate", protein: 8, tdn: 50, category: .concentrate)
        let before = try result([
            RationItem(ingredient: original, kilogramsPerAnimalPerDay: 8),
            RationItem(ingredient: replacement, kilogramsPerAnimalPerDay: 1),
            RationItem(ingredient: concentrate, kilogramsPerAnimalPerDay: 1)
        ])
        let first = try #require(RationRecommendationEngine(calculator: calculator)
            .recommend(for: before, catalog: [replacement]).first)
        #expect(Set(first.after.items.map(\.id)).count == first.after.items.count)
        #expect(abs(first.after.kilogramsPerAnimalPerDay - 10) < 1e-8)
        #expect(abs(first.after.sharePercent(for: .forage) - 90) < 1e-8)
    }

    @Test func limitsToThreeAndRanksBySeasonWithoutChangingNutrients() throws {
        let original = feed("original", protein: 8, tdn: 50)
        let before = try result([RationItem(ingredient: original, kilogramsPerAnimalPerDay: 10)])
        let candidates = ["Other A", "Other B", "Other C", "Rumput Odot", "Hay Alfalfa"].map {
            feed($0, protein: 18, tdn: 75)
        }
        let engine = RationRecommendationEngine(calculator: calculator)
        let wet = try engine.recommend(for: before, catalog: candidates, season: .wet)
        let dry = try engine.recommend(for: before, catalog: candidates, season: .dry)
        #expect(wet.count == 3)
        #expect(dry.count == 3)
        #expect(wet.first?.addedIngredient.name == "Rumput Odot")
        #expect(dry.first?.addedIngredient.name == "Hay Alfalfa")
        #expect(wet.allSatisfy { $0.meetsTargets })
        #expect(dry.allSatisfy { $0.meetsTargets })
        #expect(abs((wet.first?.replacedKilograms ?? 0) - 4) < 1e-8)
    }

    @Test func returnsNoUnnecessaryChangeWhenTargetsAlreadyMet() throws {
        let original = feed("adequate", protein: 12, tdn: 65)
        let before = try result([RationItem(ingredient: original, kilogramsPerAnimalPerDay: 10)])
        #expect(try RationRecommendationEngine(calculator: calculator).recommend(
            for: before, catalog: [feed("alternative", protein: 20, tdn: 80)]
        ).isEmpty)
    }

    @Test func ignoresDuplicateCatalogIDsAndDoesNotIntroduceMaleTriggerIngredients() throws {
        let original = feed("grass", protein: 8, tdn: 50)
        let replacement = feed("alternative", protein: 18, tdn: 75)
        let before = try result([RationItem(ingredient: original, kilogramsPerAnimalPerDay: 10)])
        let engine = RationRecommendationEngine(calculator: calculator)
        let options = try engine.recommend(for: before, catalog: [replacement, replacement])
        #expect(options.count == 1)
        var profile = before.profile
        profile.selectSex(.male)
        let male = try calculator.calculate(profile: profile, items: before.items)
        #expect(try engine.recommend(for: male, catalog: [
            feed("warning-feed", protein: 18, tdn: 75, warning: true)
        ]).isEmpty)
    }
}
