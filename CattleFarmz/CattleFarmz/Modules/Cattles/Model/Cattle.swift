//
//  Cattle.swift
//  CattleFarmz
//

import Foundation
import SwiftData

/// A cattle entry stored in the local database.
@Model
final class Cattle {
    /// Unique identifier.
    var id: UUID
    /// Name of the cattle.
    var name: String
    /// Date the cattle was acquired.
    var dateAcquired: Date

    init(
        id: UUID = UUID(),
        name: String,
        dateAcquired: Date
    ) {
        self.id = id
        self.name = name
        self.dateAcquired = dateAcquired
    }
}
