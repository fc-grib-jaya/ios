//
//  ToastConfiguration.swift
//  CattleFarmz
//

import Foundation
import SwiftUI

/// Centralizes every layout and animation constant of the toast.
///
/// Durations are in seconds. Keeping them in one value type avoids scattering
/// magic numbers across the view hierarchy.
struct ToastConfiguration {
    /// Upper bound of the expanded toast width.
    var maxWidth: CGFloat = 340
    /// Diameter of the colored circle that starts the entrance animation.
    var circleSize: CGFloat = 24
    /// Smallest height of the expanded capsule.
    var minHeight: CGFloat = 56
    /// Padding between the capsule edge and its content, on every side, so the
    /// circle sits the same distance from the left, top, and bottom edges.
    var contentPadding: CGFloat = 16
    /// Gap between the circle and the message.
    var contentSpacing: CGFloat = 10
    /// Background material of the capsule.
    var material: Material = .thinMaterial
    /// SF Symbol point size inside the circle.
    var iconSize: CGFloat = 14

    /// Distance the toast travels down from above the screen.
    var dropDuration: TimeInterval = 0.35
    /// Amplitude the circle passes below its resting position after the drop.
    var overshootBelow: CGFloat = 14
    /// Amplitude the circle passes above its resting position on the way back.
    var overshootAbove: CGFloat = 6
    /// Duration of each overshoot movement: below → above, then above → rest.
    var bounceDuration: TimeInterval = 0.2
    /// Length of the green motion trail that follows the circle during the drop.
    var trailLength: CGFloat = 320
    /// Blur radius of the motion trail.
    var trailBlurRadius: CGFloat = 8
    /// Duration of the material reveal.
    var materialDuration: TimeInterval = 0.2
    /// Duration of the horizontal expansion.
    var expandDuration: TimeInterval = 0.3
    /// Duration of the icon and text fade-in.
    var contentRevealDuration: TimeInterval = 0.2
    /// Duration of the exit fade.
    var dismissDuration: TimeInterval = 0.25

    /// Starting offset above the resting position.
    var dropDistance: CGFloat = 160
    /// Upward travel during the exit animation.
    var dismissTravel: CGFloat = 24
    /// Gap between the screen edge and the toast.
    var screenMargin: CGFloat = AppSpacing.md
    /// Gap between the safe-area top and the resting toast.
    var topInset: CGFloat = AppSpacing.xs
}
