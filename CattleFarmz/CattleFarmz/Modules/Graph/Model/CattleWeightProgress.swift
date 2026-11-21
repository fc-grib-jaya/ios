//
//  CattleWeightProgress.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 21/11/26.
//

import Foundation
import SwiftData

@Model
final class CattleWeightProgress {
    var id: UUID
    var weight: Double
    var measuredAt: Date

    // Ukuran saat pengukuran dilakukan
    var chestGirth: Double?
    var bodyLength: Double?

    var cattle: Cattle?

    init(
        id: UUID = UUID(),
        weight: Double,
        measuredAt: Date = .now,
        chestGirth: Double? = nil,
        bodyLength: Double? = nil
    ) {
        self.id = id
        self.weight = weight
        self.measuredAt = measuredAt
        self.chestGirth = chestGirth
        self.bodyLength = bodyLength
    }
}
