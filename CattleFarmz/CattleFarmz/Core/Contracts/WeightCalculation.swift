//
//  WeightCalculation.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 03/11/26.
//

import Foundation

protocol WeightCalculation {
    func weightSchoorl(chestGirth: Double) -> Double
    
    func weightWinter(chestGirth: Double, bodyLength: Double) -> Double
    
    func weightDenmark(chestGirth: Double, bodyLength: Double) -> Double

    func weightLambourne(chestGirth: Double, bodyLength: Double) -> Double
    
    func cattleWeight(
        chestGirth: Double,
        bodyLength: Double,
        breed: CattleBreed,
        gender: CattleGender
    ) -> Double
}
