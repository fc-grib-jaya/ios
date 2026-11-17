import Testing
@testable import CattleFarmz

@MainActor
struct RationRecommendationViewModelTests {
    private func feed(_ id: String, protein: Double, tdn: Double) -> FeedIngredient {
        FeedIngredient(id: id, name: id, category: .forage,
                       nutrients: NutrientContent(crudeProteinPercent: protein,
                                                  totalDigestibleNutrientsPercent: tdn,
                                                  calciumPercent: 0.5, phosphorusPercent: nil,
                                                  magnesiumPercent: nil, ironPPM: nil, copperPPM: nil, zincPPM: nil),
                       triggersGossypolWarning: false)
    }

    private func makeViewModel() throws -> RationRecommendationViewModel {
        let source = feed("grass", protein: 8, tdn: 50)
        let target = feed("odot", protein: 18, tdn: 75)
        let other = feed("raja", protein: 16, tdn: 70)
        let calculator = ManualRationCalculator { _ in
            NutrientContent(crudeProteinPercent: 10.5, totalDigestibleNutrientsPercent: 60,
                            calciumPercent: 0.35, phosphorusPercent: nil, magnesiumPercent: nil,
                            ironPPM: nil, copperPPM: nil, zincPPM: nil)
        }
        let engine = RationRecommendationEngine(calculator: calculator)
        let before = try calculator.calculate(profile: CattleRationProfile(), items: [
            RationItem(ingredient: source, kilogramsPerAnimalPerDay: 10),
            RationItem(ingredient: target, kilogramsPerAnimalPerDay: 2)
        ])
        let first = RationRecommendation(removedIngredient: source, addedIngredient: target,
                                        replacedKilograms: 4, before: before, after: before)
        let second = RationRecommendation(removedIngredient: source, addedIngredient: other,
                                         replacedKilograms: 5, before: before, after: before)
        return RationRecommendationViewModel(recommendation: first, alternatives: [first, second], engine: engine)
    }

    @Test func editingPortionImmediatelyUpdatesConcentrationsAndAmounts() throws {
        let vm = try makeViewModel()
        vm.updatePortion("2,5")
        let result = try #require(vm.scenario)
        #expect(abs(result.kilogramsPerAnimalPerDay - 12) < 1e-9)
        #expect(result.items.first { $0.id == "grass" }?.kilogramsPerAnimalPerDay == 7.5)
        #expect(result.items.first { $0.id == "odot" }?.kilogramsPerAnimalPerDay == 4.5)
        #expect(abs((result.nutrients.totalDigestibleNutrientsPercent ?? 0) - 59.375) < 1e-9)
        #expect(abs(result.nutrients.crudeProteinPercent - 11.75) < 1e-9)
        #expect(vm.selected.before.items[0].kilogramsPerAnimalPerDay == 10)
    }

    @Test func invalidPortionClearsPreviousScenarioAndRecovers() throws {
        let vm = try makeViewModel()
        for input in ["", "-1", "10.1", "nan", "inf", "text", "1,2,3"] {
            vm.updatePortion(input)
            #expect(vm.scenario == nil)
            #expect(vm.errorMessage != nil)
        }
        vm.updatePortion("0")
        let zero = try #require(vm.scenario)
        #expect(zero.items == vm.selected.before.items)
        vm.updatePortion("10")
        let full = try #require(vm.scenario)
        #expect(full.items.count == 1)
        #expect(full.items[0].kilogramsPerAnimalPerDay == 12)
        #expect(vm.errorMessage == nil)
    }

    @Test func portionUsesTwoDecimalsAndCalculatesFromTheDisplayedValue() throws {
        let vm = try makeViewModel()
        #expect(vm.portionText == "4,00")
        vm.updatePortion("2.56789")
        #expect(vm.portionText == "2,56")
        let result = try #require(vm.scenario)
        #expect(abs((result.items.first { $0.id == "grass" }?.kilogramsPerAnimalPerDay ?? 0) - 7.44) < 1e-9)
        vm.updatePortion("2,5")
        vm.finishEditingPortion()
        #expect(vm.portionText == "2,50")
    }

    @Test func switchingAlternativeKeepsPortionAndRecalculates() throws {
        let vm = try makeViewModel()
        vm.updatePortion("2")
        let first = try #require(vm.scenario)
        let other = try #require(vm.alternatives.first { $0.addedIngredient.id == "raja" })
        vm.select(other)
        let second = try #require(vm.scenario)
        #expect(vm.portionText == "2")
        #expect(second.items.first { $0.id == "raja" }?.kilogramsPerAnimalPerDay == 2)
        #expect(second.nutrients.totalDigestibleNutrientsPercent != first.nutrients.totalDigestibleNutrientsPercent)
        #expect(second.kilogramsPerAnimalPerDay == first.kilogramsPerAnimalPerDay)
    }
}
