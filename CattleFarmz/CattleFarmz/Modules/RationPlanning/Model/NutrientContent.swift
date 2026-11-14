//
//  NutrientContent.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 04/11/26.
//

struct NutrientContent: Codable, Equatable {
    let crudeProteinPercent: Double
    let totalDigestibleNutrientsPercent: Double

    let calciumPercent: Double?
    let phosphorusPercent: Double?
    let magnesiumPercent: Double?

    let ironPPM: Double?
    let copperPPM: Double?
    let zincPPM: Double?
}
