//
//  ScanResult.swift
//  CattleFarmz
//

import Foundation

/// Measurements returned by a finished LiDAR scan session.
///
/// Carries the girth and length needed downstream, mirroring the matching
/// fields of the Scanning module's `MeasurementResult`.
struct ScanResult: Sendable {
    /// Body length between the shoulder and pin landmarks, in centimeters.
    let lengthCM: Double
    /// Chest girth estimate, present when the depth fit succeeded.
    let girth: GirthEstimate?
}
