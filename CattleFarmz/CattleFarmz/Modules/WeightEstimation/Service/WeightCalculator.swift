//
//  WeightCalculator.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 03/11/26.
//

import Foundation

//@MainActor
final class WeightCalculator: WeightCalculation {
    func weightSchoorl(chestGirth: Double) -> Double {
        return pow(chestGirth+22,2)/100
    }
    
    func weightWinter(chestGirth: Double, bodyLength: Double) -> Double {
        return (pow(chestGirth,2)*bodyLength)/10815.15
    }
    
    func weightDenmark(chestGirth: Double, bodyLength: Double) -> Double {
        return pow(chestGirth,2)*0.000138*bodyLength
    }

    func weightLambourne(chestGirth: Double, bodyLength: Double) -> Double {
        return (pow(chestGirth,2)*bodyLength)/11900
    }
    
    func cattleWeight(
        chestGirth: Double,
        bodyLength: Double,
        breed: CattleBreed,
        gender: CattleGender
    ) -> Double {
        let factors = CattleWeightFactors.factors(for: breed)
        let weight: Double
        
        switch factors.formula {
        case .schoorl:
            weight = weightSchoorl(chestGirth: chestGirth)

        case .winter:
            weight = weightWinter(
                chestGirth: chestGirth,
                bodyLength: bodyLength
            )

        case .denmark:
            weight = weightDenmark(
                chestGirth: chestGirth,
                bodyLength: bodyLength
            )

        case .lambourne:
            weight = weightLambourne(
                chestGirth: chestGirth,
                bodyLength: bodyLength
            )
        }

        return weight*factors.weightFactor*factors.genderFactor(for: gender)
    }
}
