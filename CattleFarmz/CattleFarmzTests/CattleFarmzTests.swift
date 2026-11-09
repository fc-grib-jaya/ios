//
//  CattleFarmzTests.swift
//  CattleFarmzTests
//
//  Created by Muhamad Yuan Sastro Dimianta on 04/11/26.
//

import Testing
@testable import CattleFarmz

@MainActor
struct ManualRationCalculatorTests {
    
    private func loadTestCatalog() throws -> [FeedIngredient] {
        let text = try BundledFeedCSVReader().read()
        return try FeedCSVParser().parse(text)
    }
    
    private func makeCalculator() -> ManualRationCalculator {
        ManualRationCalculator { profile in
            CattleNutritionDefaults.requirements(
                for: profile.productionType,
                stage: profile.stage
            )
        }
    }
    
    private func feed(id: String) throws -> FeedIngredient {
        let ingredients = try loadTestCatalog()
        
        return try #require(
            ingredients.first { $0.id == id }
        )
    }
    
    private func exampleItems() throws -> [RationItem] {
        [
            RationItem(
                ingredient: try feed(id: "cattle-source-001"),
                kilogramsPerAnimalPerDay: 3
            ),
            RationItem(
                ingredient: try feed(id: "cattle-source-003"),
                kilogramsPerAnimalPerDay: 2
            )
        ]
    }
    
    private func approximately(
        _ actual: Double?,
        _ expected: Double
    ) -> Bool {
        guard let actual else {
            return false
        }
        
        return abs(actual - expected) < 0.000001
    }
    
    @Test
    func calculatesAllEightNutrients() throws {
        let result = try makeCalculator().calculate(
            profile: CattleRationProfile(),
            items: try exampleItems()
        )
        
        #expect(approximately(
            result.nutrients.crudeProteinPercent,
            22.92
        ))
        
        #expect(approximately(
            result.nutrients.totalDigestibleNutrientsPercent,
            63
        ))
        
        #expect(approximately(
            result.nutrients.calciumPercent,
            0.42
        ))
        
        #expect(approximately(
            result.nutrients.phosphorusPercent,
            0.42
        ))
        
        #expect(approximately(
            result.nutrients.magnesiumPercent,
            0.24
        ))
        
        #expect(approximately(result.nutrients.ironPPM, 198))
        #expect(approximately(result.nutrients.copperPPM, 12))
        #expect(approximately(result.nutrients.zincPPM, 44))
        
        #expect(approximately(
            result.proteinKilogramsPerAnimalPerDay,
            1.146
        ))
        
        #expect(approximately(
            result.tdnKilogramsPerAnimalPerDay,
            3.15
        ))
    }
    
    @Test
    func scalesHerdAmountWithoutChangingConcentrations() throws {
        let calculator = makeCalculator()
        let items = try exampleItems()
        
        let single = try calculator.calculate(
            profile: CattleRationProfile(),
            items: items
        )
        
        var profile = CattleRationProfile()
        profile.animalCount = 4
        
        let herd = try calculator.calculate(
            profile: profile,
            items: items
        )
        
        #expect(herd.kilogramsPerAnimalPerDay == 5)
        #expect(herd.kilogramsPerHerdPerDay == 20)
        #expect(herd.nutrients == single.nutrients)
        
        #expect(approximately(
            herd.sharePercent(for: .forage),
            60
        ))
        
        #expect(approximately(
            herd.sharePercent(for: .concentrate),
            40
        ))
    }
    
    @Test
    func warnsOnlyForMalesUsingPositiveTriggerAmounts() throws {
        let calculator = makeCalculator()
        
        let ingredients = try loadTestCatalog()

        let trigger = try #require(
            ingredients.first {
                $0.triggersGossypolWarning
            }
        )
        
        let activeItem = RationItem(
            ingredient: trigger,
            kilogramsPerAnimalPerDay: 1
        )
        
        var profile = CattleRationProfile()
        
        let maleResult = try calculator.calculate(
            profile: profile,
            items: [activeItem]
        )
        
        #expect(maleResult.warnings.count == 1)
        
        profile.selectSex(.female)
        
        let femaleResult = try calculator.calculate(
            profile: profile,
            items: [activeItem]
        )
        
        #expect(femaleResult.warnings.isEmpty)
        
        profile.selectSex(.male)
        
        var items = try exampleItems()
        items.append(
            RationItem(
                ingredient: trigger,
                kilogramsPerAnimalPerDay: 0
            )
        )
        
        let zeroAmountResult = try calculator.calculate(
            profile: profile,
            items: items
        )
        
        #expect(zeroAmountResult.warnings.isEmpty)
    }
    
    @Test
    func keepsMissingMineralDataUnknown() throws {
        let source = try feed(id: "cattle-source-001")
        
        let incompleteFeed = FeedIngredient(
            id: "test-incomplete-feed",
            name: "Incomplete test feed",
            category: .forage,
            nutrients: NutrientContent(
                crudeProteinPercent: 10,
                totalDigestibleNutrientsPercent: 55,
                calciumPercent: nil,
                phosphorusPercent: 0.3,
                magnesiumPercent: 0.2,
                ironPPM: 250,
                copperPPM: 10,
                zincPPM: 40
            ),
            triggersGossypolWarning: false
        )
        
        let calculator = makeCalculator()
        
        let incompleteResult = try calculator.calculate(
            profile: CattleRationProfile(),
            items: [
                RationItem(
                    ingredient: source,
                    kilogramsPerAnimalPerDay: 1
                ),
                RationItem(
                    ingredient: incompleteFeed,
                    kilogramsPerAnimalPerDay: 1
                )
            ]
        )
        
        #expect(incompleteResult.nutrients.calciumPercent == nil)
        
        let zeroAmountResult = try calculator.calculate(
            profile: CattleRationProfile(),
            items: [
                RationItem(
                    ingredient: source,
                    kilogramsPerAnimalPerDay: 1
                ),
                RationItem(
                    ingredient: incompleteFeed,
                    kilogramsPerAnimalPerDay: 0
                )
            ]
        )
        
        #expect(zeroAmountResult.nutrients == source.nutrients)
    }
    
    @Test
    func rejectsInvalidInputs() throws {
        let calculator = makeCalculator()
        let profile = CattleRationProfile()
        let ingredient = try feed(id: "cattle-source-001")
        
        #expect(throws: RationCalculationError.self) {
            try calculator.calculate(
                profile: profile,
                items: []
            )
        }
        
        for amount in [0.0, -1.0, Double.nan, Double.infinity] {
            #expect(throws: RationCalculationError.self) {
                try calculator.calculate(
                    profile: profile,
                    items: [
                        RationItem(
                            ingredient: ingredient,
                            kilogramsPerAnimalPerDay: amount
                        )
                    ]
                )
            }
        }
        
        let duplicate = RationItem(
            ingredient: ingredient,
            kilogramsPerAnimalPerDay: 1
        )
        
        #expect(throws: RationCalculationError.self) {
            try calculator.calculate(
                profile: profile,
                items: [duplicate, duplicate]
            )
        }
        
        var invalidProfile = profile
        invalidProfile.animalCount = 0
        
        #expect(throws: RationCalculationError.self) {
            try calculator.calculate(
                profile: invalidProfile,
                items: [duplicate]
            )
        }
    }
    
    @Test
    func includesTheCompleteCattleDataset() throws {
        let ingredients = try loadTestCatalog()
        
        #expect(ingredients.count == 137)
        #expect(Set(ingredients.map(\.id)).count == 137)
        
        #expect(
            ingredients.filter(\.triggersGossypolWarning).count == 2
        )
        
        for type in CattleProductionType.allCases {
            for stage in type.availableStages {
                let requirements =
                CattleNutritionDefaults.requirements(
                    for: type,
                    stage: stage
                )
                
                #expect(requirements != nil)
            }
        }
        
        #expect(
            CattleNutritionDefaults.requirements(
                for: .beef,
                stage: .highProductionLactation
            ) == nil
        )
    }
    
    @Test
    func calculatesSourceReferenceEstimates() throws {
        let calculator = makeCalculator()
        let items = try exampleItems()

        var profile = CattleRationProfile()
        profile.bodyWeightKilograms = 250
        profile.animalCount = 4

        let beef = try calculator.calculate(
            profile: profile,
            items: items
        )

        #expect(approximately(
            beef.estimatedDryMatterKilogramsPerAnimalPerDay,
            5.5
        ))

        #expect(approximately(
            beef.estimatedDryMatterKilogramsPerHerdPerDay,
            22
        ))

        #expect(beef.referenceForagePercent == 60)
        #expect(beef.referenceConcentratePercent == 40)

        profile.selectSex(.female)
        profile.selectProductionType(.dairy)

        let dairy = try calculator.calculate(
            profile: profile,
            items: items
        )

        #expect(approximately(
            dairy.estimatedDryMatterKilogramsPerAnimalPerDay,
            6.25
        ))

        #expect(dairy.referenceForagePercent == 40)
        #expect(dairy.referenceConcentratePercent == 60)
    }
}
