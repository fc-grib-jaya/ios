//
//  AppColor.swift
//  CattleFarmz
//

import SwiftUI

/// Semantic colors of the app.
///
/// Backgrounds and text use system colors so dark mode and high contrast
/// settings work without extra code.
enum AppColor {
    /// Brand color, used for primary actions.
    static let primary = Color.red

    /// Page background.
    static let background = Color(uiColor: .systemBackground)

    /// Raised surfaces such as cards.
    static let surface = Color(uiColor: .secondarySystemBackground)

    /// Primary text.
    static let textPrimary = Color(uiColor: .label)

    /// Secondary text.
    static let textSecondary = Color(uiColor: .secondaryLabel)

    /// Content drawn on top of `primary`.
    static let onPrimary = Color.white
}
