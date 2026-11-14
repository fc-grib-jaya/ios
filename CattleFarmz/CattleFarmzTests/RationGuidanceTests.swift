//
//  RationGuidanceTests.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 08/11/26.
//

import Foundation
import Testing
@testable import CattleFarmz

@MainActor
struct RationGuidanceTests {
    private func date(month: Int) throws -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone =
            try #require(TimeZone(identifier: "Asia/Jakarta"))

        return try #require(
            calendar.date(
                from: DateComponents(
                    year: 2026,
                    month: month,
                    day: 15,
                    hour: 12
                )
            )
        )
    }

    @Test
    func includesGrowthAndLargeHerdGuidance() throws {
        var profile = CattleRationProfile()
        profile.targetDailyWeightGainKilograms = 1
        profile.animalCount = 11

        let messages = RationGuidance.make(
            profile: profile,
            date: try date(month: 11)
        )

        #expect(messages.contains {
            $0.contains("target kenaikan bobot")
        })

        #expect(messages.contains {
            $0.contains("kelompok lebih dari 10 ekor")
        })

        #expect(messages.contains {
            $0.contains("musim hujan")
        })
    }

    @Test
    func includesDairyGuidanceAndChangesSeason() throws {
        var profile = CattleRationProfile()
        profile.selectSex(.female)
        profile.selectProductionType(.dairy)
        profile.dailyMilkProductionLiters = 10

        let messages = RationGuidance.make(
            profile: profile,
            date: try date(month: 6)
        )

        #expect(messages.contains {
            $0.contains("900 g protein kasar")
        })

        #expect(messages.contains {
            $0.contains("Jika sapi bunting")
        })

        #expect(messages.contains {
            $0.contains("musim kemarau")
        })

        #expect(!messages.contains {
            $0.contains("target kenaikan bobot")
        })
    }
}
