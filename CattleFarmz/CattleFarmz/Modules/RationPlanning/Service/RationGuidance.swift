//
//  RationGuidance.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 08/11/26.
//

import Foundation

enum RationGuidance {
    static func make(
        profile: CattleRationProfile,
        date: Date
    ) -> [String] {
        var messages: [String] = []

        if profile.sex == .male {
            messages.append(
                """
                Source guidance for male cattle: provide sufficient \
                energy for growth and physical activity.
                """
            )

            if profile.productionType == .beef {
                messages.append(
                    """
                    Source beef guidance: review protein supply for \
                    muscle development and consider appropriate \
                    supplementation when needed.
                    """
                )

                if profile.targetDailyWeightGainKilograms > 0.8 {
                    messages.append(
                        """
                        For a weight-gain target above 0.8 kg/day, \
                        the source suggests 12–14% crude protein \
                        and 65–70% TDN. This does not predict \
                        achieved weight gain.
                        """
                    )
                }
            }
        } else {
            if profile.productionType == .dairy {
                messages.append(
                    """
                    Source dairy guidance: review calcium and \
                    phosphorus supply. The source gives a Ca:P \
                    reference ratio of 1.5:1 to 2:1.
                    """
                )

                if profile.dailyMilkProductionLiters > 0 {
                    let extraProtein =
                        profile.dailyMilkProductionLiters * 90

                    let extraEnergy =
                        profile.dailyMilkProductionLiters * 5.5

                    messages.append(
                        """
                        Source milk-production estimates: \
                        \(extraProtein.formatted()) g additional \
                        crude protein/day and \
                        \(extraEnergy.formatted()) MJ NEL/day. \
                        These estimates are separate from the \
                        concentration targets.
                        """
                    )
                }
            }

            messages.append(
                """
                If pregnant, the source describes first-trimester \
                needs as near maintenance; second-trimester additions \
                of 10–15% protein and 10% energy; and third-trimester \
                additions of 20–25% protein and 15–20% energy. \
                It also highlights vitamins A, D, E and minerals \
                Ca, P, I and Se. No trimester adjustment is \
                automatically applied.
                """
            )
        }

        if profile.animalCount > 10 {
            messages.append(
                """
                Source herd guidance: plan ingredient supply and \
                suitable storage, consider complete feed or TMR \
                for consistency, and perform routine feed-quality checks.
                """
            )
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone =
            TimeZone(identifier: "Asia/Jakarta") ?? .gmt

        let month = calendar.component(.month, from: date)

        if [11, 12, 1, 2, 3, 4].contains(month) {
            messages.append(
                """
                Wet-season source reference, November–April: \
                protect stored feed from moisture and aflatoxin \
                contamination, use available fresh forage, and \
                review hay and silage use. Actual local \
                conditions may differ.
                """
            )
        } else {
            messages.append(
                """
                Dry-season source reference, May–October: \
                plan hay and silage stocks, use seasonal \
                agricultural by-products, review concentrate \
                supply when forage quality falls, and ensure \
                sufficient drinking water. Actual local \
                conditions may differ.
                """
            )
        }

        return messages
    }
}
