//
//  ButtonTokenGallery.swift
//  CattleFarmz
//

import SwiftUI

/// A solid button using the design system's color and spacing tokens.
private struct ButtonTokenSample: View {
    enum Variant {
        case primary
        case secondary

        func background(isPressed: Bool) -> Color {
            switch self {
            case .primary:
                isPressed ? AppColor.Button.Primary.pressedBackground : AppColor.Button.Primary.background
            case .secondary:
                isPressed ? AppColor.Button.Secondary.pressedBackground : AppColor.Button.Secondary.background
            }
        }

        func foreground(isPressed: Bool) -> Color {
            switch self {
            case .primary:
                isPressed ? AppColor.Button.Primary.pressedForeground : AppColor.Button.Primary.foreground
            case .secondary:
                isPressed ? AppColor.Button.Secondary.pressedForeground : AppColor.Button.Secondary.foreground
            }
        }
    }

    private let title: String
    private let variant: Variant
    private let action: () -> Void

    init(_ title: String, variant: Variant = .primary, action: @escaping () -> Void) {
        self.title = title
        self.variant = variant
        self.action = action
    }

    var body: some View {
        Button(title, action: action)
            .buttonStyle(ButtonTokenSampleStyle(variant: variant))
    }
}

private struct ButtonTokenSampleStyle: ButtonStyle {
    let variant: ButtonTokenSample.Variant

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.headline)
            .padding(.horizontal, AppSpacing.Button.horizontal)
            .padding(.vertical, AppSpacing.Button.vertical)
            .frame(minWidth: 44, minHeight: 44)
            .foregroundStyle(variant.foreground(isPressed: configuration.isPressed))
            .background(
                variant.background(isPressed: configuration.isPressed),
                in: RoundedRectangle(cornerRadius: AppRadius.medium)
            )
            .contentShape(RoundedRectangle(cornerRadius: AppRadius.medium))
    }
}

/// Interactive token gallery for the Xcode canvas.
private struct ButtonTokenGallery: View {
    @State private var tapCount = 0

    private let spacingScale: [(name: String, value: CGFloat)] = [
        ("xxxs", AppSpacing.xxxs), ("xxs", AppSpacing.xxs),
        ("xs", AppSpacing.xs), ("sm", AppSpacing.sm),
        ("md", AppSpacing.md), ("lg", AppSpacing.lg),
        ("xl", AppSpacing.xl), ("xxl", AppSpacing.xxl),
        ("xxxl", AppSpacing.xxxl), ("huge", AppSpacing.huge),
        ("massive", AppSpacing.massive)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                VStack(alignment: .leading, spacing: AppSpacing.contentGap) {
                    Text("Button tokens")
                        .font(AppFont.title)

                    Text("Tap to test the action. Hold to see the pressed colors.")
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.Text.secondary)

                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: AppSpacing.contentGap) { buttons }
                        VStack(alignment: .leading, spacing: AppSpacing.contentGap) { buttons }
                    }

                    Text("Taps: \(tapCount)")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.Text.muted)

                    Text("Button padding: horizontal 12 pt / vertical 8 pt")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.Text.secondary)
                }

                VStack(alignment: .leading, spacing: AppSpacing.contentGap) {
                    Text("Pressed colors")
                        .font(AppFont.headline)
                    pressedSample("Primary", variant: .primary)
                    pressedSample("Secondary", variant: .secondary)
                }

                VStack(alignment: .leading, spacing: AppSpacing.contentGap) {
                    Text("Spacing scale")
                        .font(AppFont.headline)

                    ForEach(spacingScale, id: \.name) { token in
                        HStack(spacing: AppSpacing.inlineIconGap) {
                            Text("\(token.name) · \(Int(token.value)) pt")
                                .font(AppFont.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Rectangle()
                                .fill(AppColor.Button.Primary.background)
                                .frame(width: token.value, height: AppSpacing.xs)
                        }
                    }
                }
            }
            .foregroundStyle(AppColor.Text.primary)
            .padding(AppSpacing.Card.regular)
            .background(AppColor.Card.background, in: RoundedRectangle(cornerRadius: AppRadius.large))
            .padding(AppSpacing.Screen.standard)
        }
        .background(AppColor.Surface.canvas)
    }

    @ViewBuilder
    private var buttons: some View {
        ButtonTokenSample("Primary") { tapCount += 1 }
        ButtonTokenSample("Secondary", variant: .secondary) { tapCount += 1 }
    }

    private func pressedSample(_ title: String, variant: ButtonTokenSample.Variant) -> some View {
        Text(title)
            .font(AppFont.headline)
            .padding(.horizontal, AppSpacing.Button.horizontal)
            .padding(.vertical, AppSpacing.Button.vertical)
            .foregroundStyle(variant.foreground(isPressed: true))
            .background(variant.background(isPressed: true), in: RoundedRectangle(cornerRadius: AppRadius.medium))
    }
}

#Preview("Button Tokens · Light") {
    ButtonTokenGallery()
        .preferredColorScheme(.light)
}

#Preview("Button Tokens · Dark") {
    ButtonTokenGallery()
        .preferredColorScheme(.dark)
}
