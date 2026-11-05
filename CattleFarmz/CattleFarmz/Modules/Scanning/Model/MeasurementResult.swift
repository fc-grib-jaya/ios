//
//  MeasurementResult.swift
//  CattleFarmz
//

import Foundation

enum MeasurementError: LocalizedError {
    case invalidDepth
    case depthEdge
    case invalidSection
    case insufficientSection(Int)
    case badFit(Double)
    case invalidLength

    var errorDescription: String? {
        switch self {
        case .invalidDepth:
            return "Depth tidak cukup. Pindahkan titik ke permukaan tubuh yang terlihat atau ambil ulang."
        case .depthEdge:
            return "Depth bercampur dengan latar/objek lain. Periksa titik atau ambil ulang."
        case .invalidSection:
            return "Bidang dada belum sesuai. Letakkan titik atas dan bawah tepat di belakang kaki depan."
        case .insufficientSection(let count):
            return "Depth dada hanya terbaca pada \(count) dari 31 baris. Geser titik ke satu penampang yang terlihat jelas atau ambil ulang."
        case .badFit(let residual):
            guard residual.isFinite else {
                return "Interpolasi RBF dada tidak stabil. Ambil ulang dari samping dengan depth yang lebih jelas."
            }
            return "Kurva dada tidak konsisten (residu \(Int(residual * 1000)) mm). Periksa titik atas/bawah, kaki depan yang menutupi dada, atau ambil ulang."
        case .invalidLength:
            return "Jarak titik tidak valid. Periksa titik panjang badan."
        }
    }
}

struct GirthEstimate: Codable, Sendable {
    let centimeters: Double
    let semiHeightMeters: Double
    let semiWidthMeters: Double
    let residualMeters: Double
    let validSamples: Int
    let method: String
}

struct MeasurementResult: Codable, Sendable {
    let lengthCM: Double
    let girth: GirthEstimate?
    let weightKG: Double?
    let warning: String?
    let formulaVersion: String
}
