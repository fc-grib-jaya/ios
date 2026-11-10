//
//  CattleWeightBreakdown.swift
//  CattleFarmz
//

/// Weight breakdown computed on the fly for one cattle.
/// All values are in kilograms; `nil` means it cannot be computed
/// (missing body weight or missing breed reference data).
struct CattleWeightBreakdown {
    let bodyWeight: Double?
    let carcass: Double?
    let nonCarcass: Double?
    let meat: Double?

    /// Per-part non-carcass weights in kilograms.
    /// Empty when the breakdown cannot be computed.
    let nonCarcassParts: [NonCarcassPart: Double]
}
