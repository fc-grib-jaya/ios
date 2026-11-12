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
                Sediakan energi yang cukup untuk mendukung pertumbuhan dan aktivitas fisik sapi \
                jantan.
                """
            )

            if profile.productionType == .beef {
                messages.append(
                    """
                    Untuk sapi potong, periksa kecukupan protein untuk pembentukan otot. \
                    Pertimbangkan suplemen bila diperlukan.
                    """
                )

                if profile.targetDailyWeightGainKilograms > 0.8 {
                    messages.append(
                        """
                        Untuk target kenaikan bobot di atas 0,8 kg/hari, acuan menyarankan protein kasar \
                        12–14% dan TDN 65–70%. Kenaikan bobot aktual dapat berbeda.
                        """
                    )
                }
            }
        } else {
            if profile.productionType == .dairy {
                messages.append(
                    """
                    Untuk sapi perah, periksa pasokan kalsium dan fosfor. Rasio kalsium terhadap \
                    fosfor yang digunakan sebagai acuan berkisar antara 1,5:1 dan 2:1.
                    """
                )

                if profile.dailyMilkProductionLiters > 0 {
                    let extraProtein =
                        profile.dailyMilkProductionLiters * 90

                    let extraEnergy =
                        profile.dailyMilkProductionLiters * 5.5

                    let format = FloatingPointFormatStyle<Double>.number.locale(Locale(identifier: "id_ID"))

                    messages.append(
                        """
                        Untuk produksi susu yang dimasukkan, perkiraan kebutuhan tambahan per hari \
                        adalah \(extraProtein.formatted(format)) g \
                        protein kasar dan \(extraEnergy.formatted(format)) MJ energi neto laktasi (NEL). Angka ini menyatakan kebutuhan harian. \
                        Target konsentrasi nutrisi dinilai terpisah.
                        """
                    )
                }
            }

            messages.append(
                """
                Jika sapi bunting, kebutuhan pada trimester pertama mendekati kebutuhan \
                pemeliharaan. Pada trimester kedua, acuan menyebut tambahan protein 10–15% dan \
                energi 10%. Pada trimester ketiga, tambahannya sebesar 20–25% untuk protein dan \
                15–20% untuk energi. Perhatikan juga vitamin A, D, dan E serta kalsium, fosfor, \
                iodium, dan selenium. Penyesuaian ransum per trimester dilakukan secara manual.
                """
            )
        }

        if profile.animalCount > 10 {
            messages.append(
                """
                Untuk kelompok lebih dari 10 ekor, rencanakan pasokan dan penyimpanan bahan \
                pakan. Pertimbangkan pakan lengkap atau ransum campuran total (TMR) agar \
                komposisinya konsisten. Periksa mutu pakan secara rutin.
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
                Pada musim hujan (November–April menurut acuan), lindungi stok pakan dari \
                kelembapan dan kontaminasi aflatoksin. Manfaatkan hijauan segar yang tersedia \
                dan evaluasi penggunaan hay (hijauan kering) serta silase. Sesuaikan dengan \
                kondisi setempat.
                """
            )
        } else {
            messages.append(
                """
                Pada musim kemarau (Mei–Oktober menurut acuan), rencanakan stok hijauan kering \
                dan silase. Manfaatkan hasil samping pertanian musiman, periksa pasokan \
                konsentrat jika mutu hijauan menurun, dan sediakan air minum yang cukup. \
                Sesuaikan dengan kondisi setempat.
                """
            )
        }

        return messages
    }
}
