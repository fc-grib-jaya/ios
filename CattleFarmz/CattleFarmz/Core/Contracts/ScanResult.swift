//
//  ScanResult.swift
//  CattleFarmz
//

import Foundation

/// Measurements returned by a finished LiDAR scan session.
///
/// The `App` layer hands this value from the Scanning module to whichever
/// module opened the session, so it lives in `Core/Contracts` and never
/// mentions a module type.
struct ScanResult: Equatable, Sendable {
    /// Body length between the shoulder and pin landmarks, in centimeters.
    let lengthCM: Double
    /// Chest girth, present when the depth fit succeeded.
    let girthCM: Double?
    /// Estimated body weight, present when both measurements were available.
    let weightKG: Double?
}
