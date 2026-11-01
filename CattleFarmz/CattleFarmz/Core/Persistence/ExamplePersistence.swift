//
//  ExamplePersistence.swift
//  CattleFarmz
//

/// Storage abstractions belong in `Core/Persistence`.
///
/// Declare one protocol per storage concern, for example `ScanHistoryStore`,
/// and implement it with SwiftData, Core Data, or files in this folder. Modules
/// depend on the protocol, never on the concrete implementation.
protocol ExamplePersistence {
    /// Empty on purpose: this file only demonstrates where persistence lives.
}
