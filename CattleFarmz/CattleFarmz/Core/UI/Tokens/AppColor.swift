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
    static let primary = Color(#colorLiteral(red: 0.06274509804, green: 0.3450980392, blue: 0, alpha: 1))

    /// Page background.
    static let background = Color(uiColor: .systemBackground)

    /// Raised surfaces such as cards.
    static let surface = Color(uiColor: .secondarySystemBackground)

    /// Primary text.
    static let textPrimary = Color(uiColor: .label)

    /// Secondary text.
    static let textSecondary = Color(uiColor: .secondaryLabel)
    
    static let textRequired = Color.red
    static let textBrown = Color(#colorLiteral(red: 0.4745098039, green: 0.3294117647, blue: 0.1647058824, alpha: 1))

    /// Content drawn on top of `primary`.
    static let onPrimary = Color.white
}
