//
//  ExampleContract.swift
//  CattleFarmz
//

/// Cross-module protocols and their shared models belong in `Core/Contracts`.
///
/// Name files after the contract they declare, for example `CattleScanning.swift`
/// for a `CattleScanning` protocol. Modules depend on these contracts, so a
/// contract must never mention a type from `Modules` or `App`.
protocol ExampleContract {
    /// Empty on purpose: this file only demonstrates where contracts live.
}
