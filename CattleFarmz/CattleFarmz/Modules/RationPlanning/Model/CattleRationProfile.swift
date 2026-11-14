//
//  CattleRationProfile.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 04/11/26.
//

enum CattleProductionType: String, Codable, CaseIterable, Identifiable {
    case beef = "Beef cattle"
    case dairy = "Dairy cattle"
    
    var id: Self { self }
    
    var availableStages: [CattleProductionStage] {
        switch self {
        case .beef:
            [
                .calf,
                .growing,
                .adult,
                .pregnant,
                .fattening
            ]
            
        case .dairy:
            [
                .calf,
                .heifer,
                .pregnantHeifer,
                .lowProductionLactation,
                .highProductionLactation,
                .dry
            ]
        }
    }
}

enum CattleProductionStage: String, Codable, Identifiable {
    case calf = "Calf under 6 months"
    case growing = "Growing, 6–12 months"
    case adult = "Adult over 12 months"
    case pregnant = "Pregnant"
    case fattening = "Fattening"
    
    case heifer = "Heifer, 6–12 months"
    case pregnantHeifer = "Pregnant heifer"
    case lowProductionLactation = "Low production lactation"
    case highProductionLactation = "High production lactation"
    case dry = "Dry period"
    
    var id: Self { self }
    
    var requiresFemale: Bool {
        switch self {
        case .pregnant,
                .heifer,
                .pregnantHeifer,
                .lowProductionLactation,
                .highProductionLactation,
                .dry:
            true
            
        case .calf, .growing, .adult, .fattening:
            false
        }
    }
}

enum CattleSex: String, Codable, CaseIterable, Identifiable {
    case male = "Male"
    case female = "Female"
    
    var id: Self { self }
}

struct CattleRationProfile: Codable, Equatable {
    private(set) var productionType: CattleProductionType = .beef
    private(set) var sex: CattleSex = .male
    private(set) var stage: CattleProductionStage = .adult
    
    var animalCount: Int = 1
    var bodyWeightKilograms: Double = 250
    
    var targetDailyWeightGainKilograms: Double = 0.5
    var dailyMilkProductionLiters: Double = 0
    
    var availableStages: [CattleProductionStage] {
        productionType.availableStages.filter {
            sex == .female || !$0.requiresFemale
        }
    }
    
    var usesWeightGainTarget: Bool {
        productionType == .beef
    }
    
    var usesMilkProduction: Bool {
        productionType == .dairy && sex == .female
    }
    
    mutating func selectProductionType(
        _ productionType: CattleProductionType
    ) {
        self.productionType = productionType
        normalizeStage()
    }
    
    mutating func selectSex(_ sex: CattleSex) {
        self.sex = sex
        normalizeStage()
    }
    
    mutating func selectStage(
        _ stage: CattleProductionStage
    ) {
        guard availableStages.contains(stage) else {
            return
        }
        
        self.stage = stage
    }
    
    private mutating func normalizeStage() {
        if !availableStages.contains(stage) {
            stage = .calf
        }
    }
}
