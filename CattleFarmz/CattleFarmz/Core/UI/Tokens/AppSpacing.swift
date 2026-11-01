//
//  AppSpacing.swift
//  CattleFarmz
//

import CoreGraphics

/// Spacing scale of the app, in points.
enum AppSpacing {
    /// 2 pt: hairline separation inside a compact control.
    static let xxs: CGFloat = 2
    /// 4 pt: separation between tightly related elements.
    static let xs: CGFloat = 4
    /// 8 pt: separation inside a component.
    static let small: CGFloat = 8
    /// 16 pt: default separation between elements.
    static let medium: CGFloat = 16
    /// 24 pt: separation between groups.
    static let large: CGFloat = 24
    /// 32 pt: separation between sections.
    static let xl: CGFloat = 32
    /// 48 pt: page-level breathing room.
    static let xxl: CGFloat = 48
}
