//
//  Cattle.swift
//  CattleFarmz
//

import Foundation
import SwiftData

enum CattleBreed: String, Codable, CaseIterable, Identifiable {
    case bali = "Bali"
    case madura = "Madura"
    case limousin = "Limousin"
    case simmental = "Simmental"
    case brahman = "Brahman"
    case peranakanOngole = "Peranakan Ongole"
    case friesianHolstein = "Friesian Holstein"
    case aceh = "Aceh"

    var id: String { rawValue }
}

enum CattleGender: String, Codable, CaseIterable, Identifiable{
    case male = "Jantan"
    case female = "Betina"
    
    var id: String { rawValue }
}

enum CattleAgeRange: String, Codable, CaseIterable, Identifiable{
    case baby = "0-6 Bulan"
    case veryYoung = "6-12 Bulan"
    case young = "12-18 Bulan"
    case mature = "18-24 Bulan"
    case old = ">24 Bulan"
    
    var id: String { rawValue }
}

/// A cattle entry stored in the local database.
@Model
final class Cattle {
    /// Unique identifier.
    var id: UUID
    /// Name of the cattle.
    var name: String
    /// Date the cattle was acquired.
    var dateAcquired: Date
    var birthDate: Date?
    
    /// For Weight Factor
    var breed: CattleBreed
    var gender: CattleGender
    
    var recordedAge: Int
    var currentAge: Int {
        let elapsedMonths = Calendar.current.dateComponents(
            [.month],
            from: dateAcquired,
            to: .now
        ).month ?? 0

        return recordedAge + max(0, elapsedMonths)
    }
    
    /// For Weight Calculation
    var chestGirth: Double?
    var bodyLength: Double?
    var bodyWeight: Double?
    
    @Attribute(.externalStorage)
    var cattleImage: Data?
    
    var savedRation: Data?
    var rationUpdatedAt: Date?
    var rationTargetADG: Double?

    var notes: String?

    init(
        id: UUID = UUID(),
        name: String,
        dateAcquired: Date,
        breed: CattleBreed,
        gender: CattleGender,
        recordedAge: Int,
        chestGirth: Double? = nil,
        bodyLength: Double? = nil,
        bodyWeight: Double? = nil,
        cattleImage: Data? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.dateAcquired = dateAcquired
        self.breed = breed
        self.gender = gender
        self.recordedAge = recordedAge
        self.chestGirth = chestGirth
        self.bodyLength = bodyLength
        self.bodyWeight = bodyWeight
        self.cattleImage = cattleImage
        self.notes = notes
    }
}
