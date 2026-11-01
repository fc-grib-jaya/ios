//
//  AppRadius.swift
//  CattleFarmz
//

import CoreGraphics

/// Corner radius scale of the app, in points.
enum AppRadius {
    /// 8 pt: small controls and chips.
    static let small: CGFloat = 8
    /// 12 pt: inputs and compact cards.
    static let medium: CGFloat = 12
    /// 20 pt: cards and sheets.
    static let large: CGFloat = 20
    /// 999 pt: fully rounded, used for capsules.
    static let full: CGFloat = 999
}
