//
//  WeightFactor.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 03/11/26.
//

enum WeightFormula {
    case schoorl
    case winter
    case denmark
    case lambourne
    case djagra
}

struct CattleWeightFactors {
    let formula: WeightFormula
    let weightFactor: Double
    let maleFactor: Double
    let femaleFactor: Double

    func genderFactor(for gender: CattleGender) -> Double {
        switch gender {
        case .male:
            return maleFactor
        case .female:
            return femaleFactor
        }
    }

    static func factors(for breed: CattleBreed) -> CattleWeightFactors {
        switch breed {
        case .bali:
            return .init(formula: .djagra, weightFactor: 1, maleFactor: 1, femaleFactor: 0.98)
        case .madura:
            return .init(formula: .schoorl, weightFactor: 0.95, maleFactor: 1.15, femaleFactor: 0.92)
        case .limousin:
            return .init(formula: .winter, weightFactor: 1.2, maleFactor: 1.12, femaleFactor: 0.95)
        case .simmental:
            return .init(formula: .winter, weightFactor: 1.25, maleFactor: 1.1, femaleFactor: 0.93)
        case .brahman:
            return .init(formula: .winter, weightFactor: 1.15, maleFactor: 1.18, femaleFactor: 0.9)
        case .peranakanOngole:
            return .init(formula: .lambourne, weightFactor: 1.05, maleFactor: 1.12, femaleFactor: 0.9)
        case .friesianHolstein:
            return .init(formula: .denmark, weightFactor: 1.1, maleFactor: 1.08, femaleFactor: 0.97)
        case .aceh:
            return .init(formula: .schoorl, weightFactor: 0.9, maleFactor: 1.14, femaleFactor:0.92)
        }
    }
}
