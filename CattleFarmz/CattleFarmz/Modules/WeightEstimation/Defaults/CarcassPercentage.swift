//
//  CarcassPercentage.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 03/11/26.
//

enum NonCarcassPart: String, CaseIterable {
    case kepala
    case kulit
    case kaki
    case ekor
    case darah
    case jantung
    case hati
    case paru
    case limpa
    case pencernaan
    case lemak
}

extension NonCarcassPart {
    var displayName: String {
        switch self {
        case .kepala: "Kepala"
        case .kulit: "Kulit"
        case .kaki: "Kaki"
        case .ekor: "Ekor"
        case .darah: "Darah"
        case .jantung: "Jantung"
        case .hati: "Hati"
        case .paru: "Paru-Paru"
        case .limpa: "Limpa"
        case .pencernaan: "Pencernaan"
        case .lemak: "Lemak"
        }
    }
}

struct Carcass {
    let maleCarcassPercent: Double
    let femaleCarcassPercent: Double
    let nonCarcassPercent: [NonCarcassPart: Double]
    let meatPercentOfCarcass: Double
    let reference: String

    func carcassPercent(for gender: CattleGender) -> Double {
        switch gender {
        case .male: maleCarcassPercent
        case .female: femaleCarcassPercent
        }
    }
}

enum CarcassPercentage {
    static func percentage(for breed: CattleBreed) -> Carcass? {
        switch breed {
        case .bali:
            Carcass(
                maleCarcassPercent: 52.5,
                femaleCarcassPercent: 49.0,
                nonCarcassPercent: [
                    .kepala: 6.5,
                    .kulit: 8.0,
                    .kaki: 2.3,
                    .ekor: 0.5,
                    .darah: 3.5,
                    .jantung: 0.5,
                    .hati: 1.5,
                    .paru: 1.0,
                    .limpa: 0.3,
                    .pencernaan: 15.0,
                    .lemak: 5.0
                ],
                meatPercentOfCarcass: 75.0,
                reference: "Soeparno. (2011). Ilmu Nutrisi dan Teknologi Daging. Gadjah Mada University Press."
            )
            
        case .madura:
            Carcass(
                maleCarcassPercent: 51.0,
                femaleCarcassPercent: 48.0,
                nonCarcassPercent: [
                    .kepala: 7.0,
                    .kulit: 8.5,
                    .kaki: 2.5,
                    .ekor: 0.5,
                    .darah: 3.5,
                    .jantung: 0.4,
                    .hati: 1.4,
                    .paru: 1.0,
                    .limpa: 0.3,
                    .pencernaan: 16.0,
                    .lemak: 5.0
                ],
                meatPercentOfCarcass: 72.0,
                reference: "Hafid, H. dan R. Priyanto. (2006). Pertumbuhan dan Distribusi Potongan Komersial Karkas Sapi Madura. J. Ilmiah Ilmu-Ilmu Peternakan, 9(2), 65-73."
            )
            
        case .limousin:
            Carcass(
                maleCarcassPercent: 58.0,
                femaleCarcassPercent: 54.0,
                nonCarcassPercent: [
                    .kepala: 5.5,
                    .kulit: 7.2,
                    .kaki: 2.0,
                    .ekor: 0.4,
                    .darah: 3.0,
                    .jantung: 0.4,
                    .hati: 1.2,
                    .paru: 0.8,
                    .limpa: 0.2,
                    .pencernaan: 12.0,
                    .lemak: 4.0
                ],
                meatPercentOfCarcass: 80.0,
                reference: "Chambaz, A., et al. (2003). Meat quality of Angus, Simmental, Charolais and Limousin steers. Animal Science, 77, 119-129."
            )
            
        case .simmental:
            Carcass(
                maleCarcassPercent: 57.0,
                femaleCarcassPercent: 53.0,
                nonCarcassPercent: [
                    .kepala: 5.6,
                    .kulit: 7.4,
                    .kaki: 2.0,
                    .ekor: 0.4,
                    .darah: 3.2,
                    .jantung: 0.4,
                    .hati: 1.3,
                    .paru: 0.9,
                    .limpa: 0.2,
                    .pencernaan: 12.5,
                    .lemak: 4.5
                ],
                meatPercentOfCarcass: 78.0,
                reference: "Chambaz, A., et al. (2003). Meat quality of Angus, Simmental, Charolais and Limousin steers. Animal Science, 77, 119-129."
            )
        
        case .brahman:
            Carcass(
                maleCarcassPercent: 55.0,
                femaleCarcassPercent: 51.0,
                nonCarcassPercent: [
                    .kepala: 6.0,
                    .kulit: 7.8,
                    .kaki: 2.1,
                    .ekor: 0.4,
                    .darah: 3.2,
                    .jantung: 0.4,
                    .hati: 1.3,
                    .paru: 0.9,
                    .limpa: 0.2,
                    .pencernaan: 13.5,
                    .lemak: 4.0
                ],
                meatPercentOfCarcass: 77.0,
                reference: "Cole, J.W., et al. (1964). Effects of Type and Breed of British, Zebu and Dairy Cattle on Production, Carcass Composition and Palatability. J Animal Science, 23, 115-120."
            )
            
        case .peranakanOngole:
            Carcass(
                maleCarcassPercent: 50.0,
                femaleCarcassPercent: 47.0,
                nonCarcassPercent: [
                    .kepala: 7.0,
                    .kulit: 8.5,
                    .kaki: 2.5,
                    .ekor: 0.5,
                    .darah: 3.5,
                    .jantung: 0.4,
                    .hati: 1.4,
                    .paru: 1.0,
                    .limpa: 0.3,
                    .pencernaan: 16.5,
                    .lemak: 5.5
                ],
                meatPercentOfCarcass: 70.0,
                reference: "Priyanto, R., et al. (1999). Karakteristik Karkas dan Non-Karkas Sapi Peranakan Ongole. Media Veteriner, 6(4), 13-17."
            )
            
        case .friesianHolstein:
            Carcass(
                maleCarcassPercent: 53.0,
                femaleCarcassPercent: 48.0,
                nonCarcassPercent: [
                    .kepala: 6.2,
                    .kulit: 8.0,
                    .kaki: 2.2,
                    .ekor: 0.5,
                    .darah: 3.3,
                    .jantung: 0.4,
                    .hati: 1.4,
                    .paru: 1.0,
                    .limpa: 0.3,
                    .pencernaan: 15.0,
                    .lemak: 6.0
                ],
                meatPercentOfCarcass: 72.0,
                reference: "Purchas, R.W., et al. (2002). Effects of growth potential and growth path on tenderness of beef. J Animal Science, 80, 3211-3221."
            )
            
        case .aceh:
            Carcass(
                maleCarcassPercent: 49.0,
                femaleCarcassPercent: 46.0,
                nonCarcassPercent: [
                    .kepala: 7.2,
                    .kulit: 8.8,
                    .kaki: 2.7,
                    .ekor: 0.5,
                    .darah: 3.5,
                    .jantung: 0.4,
                    .hati: 1.4,
                    .paru: 1.0,
                    .limpa: 0.3,
                    .pencernaan: 17.0,
                    .lemak: 5.5
                ],
                meatPercentOfCarcass: 68.0,
                reference: "Abdullah, M., et al. (2007). Karakteristik Karkas dan Non Karkas Sapi Aceh. J. Agripet, 7(1), 41-45."
            )
        }
    }
}
