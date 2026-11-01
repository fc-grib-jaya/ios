//
//  AppFont.swift
//  CattleFarmz
//

import SwiftUI

/// Typography scale of the app.
///
/// Every font is derived from a system text style, so Dynamic Type scaling is
/// preserved.
enum AppFont {
    /// Screen-level headline, for example on the splash screen.
    static let largeTitle = Font.system(.largeTitle, weight: .bold)

    /// Section or page title.
    static let title = Font.system(.title2, weight: .semibold)

    /// Emphasised labels and buttons.
    static let headline = Font.system(.headline)

    /// Default body copy.
    static let body = Font.system(.body)

    /// Supporting and secondary copy.
    static let caption = Font.system(.caption)
}
