//
//  ToastLayout.swift
//  CattleFarmz
//

import Foundation
import SwiftUI
import UIKit

/// Precomputed sizes of one toast at its current typography and available width.
///
/// The text is measured before the expansion starts, so the animation only
/// animates stored values instead of chasing layout.
struct ToastLayout: Equatable {
    let initialWidth: CGFloat
    let initialHeight: CGFloat
    let targetWidth: CGFloat
    let targetHeight: CGFloat
    let textWidth: CGFloat

    static func make(
        message: String,
        configuration: ToastConfiguration,
        availableWidth: CGFloat,
        dynamicTypeSize: DynamicTypeSize
    ) -> ToastLayout {
        let circle = configuration.circleSize
        let padding = configuration.contentPadding

        let initialWidth = circle + padding * 2
        // While only the circle is visible the capsule stays a dot, so the
        // material reveal does not show a narrow vertical pill.
        let initialHeight = initialWidth

        let available = availableWidth > 0
            ? availableWidth - configuration.screenMargin * 2
            : configuration.maxWidth
        let maxAllowed = max(initialWidth, min(configuration.maxWidth, available))

        let idealTextWidth = ToastTextMetrics.idealWidth(
            message,
            dynamicTypeSize: dynamicTypeSize
        )
        let intrinsicWidth = idealTextWidth
            + padding * 2
            + circle
            + configuration.contentSpacing
        let targetWidth = min(maxAllowed, max(initialWidth, intrinsicWidth))

        let textWidth = max(
            0,
            targetWidth - padding * 2 - circle - configuration.contentSpacing
        )
        let textHeight = ToastTextMetrics.height(
            message,
            width: textWidth,
            dynamicTypeSize: dynamicTypeSize
        )
        // One extra point absorbs fractional rounding differences between the
        // measured height and the text layout.
        let targetHeight = max(
            configuration.minHeight,
            textHeight + padding * 2 + 1
        )

        return ToastLayout(
            initialWidth: initialWidth,
            initialHeight: initialHeight,
            targetWidth: targetWidth,
            targetHeight: targetHeight,
            textWidth: textWidth
        )
    }
}

/// Measures the toast message with the same font and Dynamic Type scaling the
/// view uses, without allocating a hosting view.
private enum ToastTextMetrics {
    /// `subheadline` text style, matching `AppFont.mediumSubheadline`.
    private static let textStyle: UIFont.TextStyle = .subheadline
    /// Default point size of the `subheadline` text style.
    private static let basePointSize: CGFloat = 15

    static func idealWidth(_ message: String, dynamicTypeSize: DynamicTypeSize) -> CGFloat {
        let size = (message as NSString).size(
            withAttributes: [.font: font(for: dynamicTypeSize)]
        )
        return ceil(size.width)
    }

    static func height(
        _ message: String,
        width: CGFloat,
        dynamicTypeSize: DynamicTypeSize
    ) -> CGFloat {
        guard width > 0 else { return 0 }
        let rect = (message as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font(for: dynamicTypeSize)],
            context: nil
        )
        return ceil(rect.height)
    }

    private static func font(for dynamicTypeSize: DynamicTypeSize) -> UIFont {
        UIFontMetrics(forTextStyle: textStyle).scaledFont(
            for: UIFont.systemFont(ofSize: basePointSize, weight: .medium),
            compatibleWith: UITraitCollection(
                preferredContentSizeCategory: dynamicTypeSize.contentSizeCategory
            )
        )
    }
}

private extension DynamicTypeSize {
    var contentSizeCategory: UIContentSizeCategory {
        switch self {
        case .xSmall: .extraSmall
        case .small: .small
        case .medium: .medium
        case .large: .large
        case .xLarge: .extraLarge
        case .xxLarge: .extraExtraLarge
        case .xxxLarge: .extraExtraExtraLarge
        case .accessibility1: .accessibilityMedium
        case .accessibility2: .accessibilityLarge
        case .accessibility3: .accessibilityExtraLarge
        case .accessibility4: .accessibilityExtraExtraLarge
        case .accessibility5: .accessibilityExtraExtraExtraLarge
        @unknown default: .large
        }
    }
}
