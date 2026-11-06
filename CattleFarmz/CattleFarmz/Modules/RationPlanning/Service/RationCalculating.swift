//
//  RationCalculating.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 04/11/26.
//

import Foundation

protocol RationCalculating {
    func calculate(
        profile: CattleRationProfile,
        items: [RationItem]
    ) throws -> RationCalculationResult
}

enum RationCalculationError: LocalizedError {
    case invalidProfile
    case unavailableRequirements
    case invalidAmount
    case emptyRation
    case duplicateIngredient
    case invalidIngredient
    case numericOverflow

    var errorDescription: String? {
        switch self {
        case .invalidProfile:
            return "Enter a valid cattle profile."

        case .unavailableRequirements:
            return "Reference requirements are unavailable for this production stage."

        case .invalidAmount:
            return "Feed amounts must be finite, non-negative numbers."

        case .emptyRation:
            return "Add at least one feed amount greater than zero."

        case .duplicateIngredient:
            return "Each ingredient may appear only once."

        case .invalidIngredient:
            return "An ingredient contains invalid identity or nutrient data."

        case .numericOverflow:
            return "The entered values are too large to calculate."
        }
    }
}
