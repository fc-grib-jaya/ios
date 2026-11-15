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
    private enum Face {
        static let regular  = "PlusJakartaSans-Regular"
        static let medium   = "PlusJakartaSans-Medium"
        static let semibold = "PlusJakartaSans-SemiBold"
        static let bold     = "PlusJakartaSans-Bold"
    }

    /// Screen-level headline, for example on the splash screen.
    static let largeTitle = Font.custom(Face.bold, size: 34, relativeTo: .largeTitle)

    /// Section or page title.
    static let title = Font.custom(Face.semibold, size: 22, relativeTo: .title2)

    /// Emphasised labels and buttons.
    static let headline = Font.custom(Face.semibold, size: 17, relativeTo: .headline)

    /// Default body copy.
    static let body = Font.custom(Face.regular, size: 17, relativeTo: .body)
    static let mediumBody = Font.custom(Face.medium, size: 17, relativeTo: .body)

    /// Supporting labels, for example a toast message.
    static let mediumSubheadline = Font.custom(Face.medium, size: 15, relativeTo: .subheadline)

    /// Supporting and secondary copy.
    static let caption = Font.custom(Face.regular, size: 12, relativeTo: .caption)
}
