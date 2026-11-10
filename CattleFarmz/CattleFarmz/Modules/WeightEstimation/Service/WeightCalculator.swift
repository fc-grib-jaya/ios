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
    
    func weightDjagra(chestGirth: Double, bodyLength: Double) -> Double {
        return (pow(chestGirth,2)*bodyLength)/11045
    }
    
    func cattleWeight(
        chestGirth: Double,
        bodyLength: Double?,
        breed: CattleBreed,
        gender: CattleGender
    ) -> Double? {
        guard chestGirth.isFinite, chestGirth > 0 else {
            return nil
        }
        
        let factors = CattleWeightFactors.factors(for: breed)
        let weight: Double
        
        if factors.formula != .schoorl {
            guard let bodyLength,
                  bodyLength.isFinite,
                  bodyLength > 0 else {
                return nil
            }
        }
        
        switch factors.formula {
        case .schoorl:
            weight = weightSchoorl(chestGirth: chestGirth)

        case .winter:
            guard let bodyLength else { return nil }
            weight = weightWinter(
                chestGirth: chestGirth,
                bodyLength: bodyLength
            )

        case .denmark:
            guard let bodyLength else { return nil }
            weight = weightDenmark(
                chestGirth: chestGirth,
                bodyLength: bodyLength
            )

        case .lambourne:
            guard let bodyLength else { return nil }
            weight = weightLambourne(
                chestGirth: chestGirth,
                bodyLength: bodyLength
            )
        
        case .djagra:
            guard let bodyLength else { return nil }
            weight = weightDjagra(
                chestGirth: chestGirth,
                bodyLength: bodyLength
            )
        }
        
        let result = weight*factors.weightFactor*factors.genderFactor(for: gender)

        return result.isFinite && result > 0 ? result : nil
    }
    
    func carcassWeight(breed: CattleBreed, gender: CattleGender, bodyWeight: Double) -> Double? {
        guard bodyWeight.isFinite, bodyWeight > 0,
              let reference = CarcassPercentage.percentage(for: breed) else {
            return nil
        }

        let percent = reference.carcassPercent(for: gender)
        return bodyWeight * percent/100
    }
    
    func nonCarcassWeight(breed: CattleBreed, bodyWeight: Double, part: NonCarcassPart) -> Double? {
        guard bodyWeight.isFinite, bodyWeight > 0,
              let reference = CarcassPercentage.percentage(for: breed),
              let percent = reference.nonCarcassPercent[part] else {
            return nil
        }

        return bodyWeight * percent/100
    }
    
    func meatWeight(breed: CattleBreed, gender: CattleGender, bodyWeight: Double) -> Double? {
        guard bodyWeight.isFinite, bodyWeight > 0,
              let reference = CarcassPercentage.percentage(for: breed),
              let carcass = carcassWeight(breed: breed, gender: gender, bodyWeight: bodyWeight) else {
            return nil
        }
        
        return carcass * reference.meatPercentOfCarcass/100
    }
}
