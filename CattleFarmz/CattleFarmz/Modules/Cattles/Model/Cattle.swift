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

enum CattleGender: String, Codable, CaseIterable {
    case male = "Jantan"
    case female = "Betina"
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
    
    /// For Weight Factor
    var breed: CattleBreed
    var gender: CattleGender
    
    /// For Weight Calculation
    var chestGirth: Double?
    var bodyLength: Double?
    var bodyWeight: Double?

    init(
        id: UUID = UUID(),
        name: String,
        dateAcquired: Date,
        breed: CattleBreed,
        gender: CattleGender,
        chestGirth: Double? = nil,
        bodyLength: Double? = nil,
        bodyWeight: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.dateAcquired = dateAcquired
        self.breed = breed
        self.gender = gender
        self.chestGirth = chestGirth
        self.bodyLength = bodyLength
        self.bodyWeight = bodyWeight
    }
}
