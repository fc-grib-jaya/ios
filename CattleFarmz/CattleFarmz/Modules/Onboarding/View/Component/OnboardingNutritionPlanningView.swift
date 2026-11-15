//
//  OnboardingNutritionPlanningView.swift
//  CattleFarmz
//

import SwiftUI

/// Custom content for the nutrition planning onboarding screen: four images
/// pinned to the corners of a fixed-height container with an empty glass
/// rectangle in the center.
struct OnboardingNutritionPlanningView: View {
    /// Bounds the visual so it does not stretch to the full screen height.
    private let containerHeight: CGFloat = 320
    private let imageSize: CGFloat = 144
    private let cardSize = CGSize(width: 150, height: 210)
    private let cardCornerRadius: CGFloat = 24

    var body: some View {
        ZStack {
            cornerImages

            centerCard
        }
        .frame(maxWidth: .infinity)
        .frame(height: containerHeight)
        .padding(.top, 48)
    }

    /// One image per corner of the container, centered on the corner point
    /// so half of it hangs past the edge. Each image is positioned
    /// absolutely, so resizing one never shifts the others.
    private var cornerImages: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(imageConfigs.enumerated()), id: \.offset) {
                    _,
                    config in
                    cornerImage(config)
                        .position(
                            x: config.x < 0 ? 0 : geometry.size.width,
                            y: config.y < 0 ? 0 : geometry.size.height
                        )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: containerHeight)
    }

    /// Per-image placement. Each image is independent: `x`/`y` (-1 or 1)
    /// pick the corner, `rotation` spins it, `scale` multiplies its size,
    /// and `extraOffsetX` adds a horizontal shift as a fraction of its size.
    private let imageConfigs: [CornerImageConfig] = [
        CornerImageConfig(
            name: "2-1",
            x: 1,
            y: 1,
            rotation: .degrees(-30),
            scale: 1.8,
            extraOffsetX: 0.12
        ),
        CornerImageConfig(
            name: "2-2",
            x: 1,
            y: -1,
            scale: 1.6,
            extraOffsetX: -0.08
        ),
        CornerImageConfig(name: "2-3", x: -1, y: 1, scale: 2.5),
        CornerImageConfig(
            name: "2-4",
            x: -1,
            y: -1,
            rotation: .degrees(90),
            scale: 3,
            extraOffsetX: -0.12
        ),
    ]

    private func cornerImage(_ config: CornerImageConfig) -> some View {
        let size = imageSize * config.scale
        return Image(config.name)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .rotationEffect(config.rotation)
            .offset(x: config.extraOffsetX * size, y: 0)
            // Same card shadow as the other onboarding visuals.
            .shadow(
                color: Color(
                    red: 0.000,
                    green: 0.000,
                    blue: 0.000,
                    opacity: 0.05
                ),
                radius: 5,
                x: 0,
                y: 4
            )
    }

    /// Empty rounded rectangle with a secondary-tinted glass effect.
    private var centerCard: some View {
        RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
            .fill(Color.clear)
            .frame(width: cardSize.width, height: cardSize.height)
            .glassEffect(
                .regular.tint(AppColor.Primitive.Secondary.shade500),
                in: RoundedRectangle(
                    cornerRadius: cardCornerRadius,
                    style: .continuous
                )
            )
            .shadow(
                color: Color(
                    red: 0.000,
                    green: 0.000,
                    blue: 0.000,
                    opacity: 0.05
                ),
                radius: 5,
                x: 0,
                y: 4
            )
    }
}

/// Placement settings for a single corner image.
private struct CornerImageConfig {
    let name: String
    /// -1 = left edge, 1 = right edge.
    let x: CGFloat
    /// -1 = top edge, 1 = bottom edge.
    let y: CGFloat
    var rotation: Angle = .zero
    var scale: CGFloat = 1
    var extraOffsetX: CGFloat = 0
}

#Preview {
    OnboardingNutritionPlanningView()
        .padding(AppSpacing.massive)
        .background(AppColor.Surface.canvas)
}
