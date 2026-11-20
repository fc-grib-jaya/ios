//
//  OnboardingNutritionPlanningView.swift
//  CattleFarmz
//

import SwiftUI

/// Custom content for the nutrition planning onboarding screen: four images
/// pinned to the corners of a fixed-height container with an empty glass
/// rectangle in the center.
struct OnboardingNutritionPlanningView: View {
    /// True while this onboarding page is the selected one. The visual
    /// stays hidden until then so a partial swipe does not reveal it early.
    var isActive: Bool = false

    /// Bounds the visual so it does not stretch to the full screen height.
    private let containerHeight: CGFloat = 320
    private let imageSize: CGFloat = 144
    private let cardSize = CGSize(width: 240, height: 180)
    private let cardCornerRadius: CGFloat = 24

    /// Drives the entrance: hidden until the page becomes active.
    @State private var appeared = false

    /// Smaller iPhone screens (under 880pt tall, i.e. not Plus / Pro Max)
    /// get the visual pushed down slightly; bigger screens are unchanged.
    private var extraTopOffset: CGFloat {
        UIScreen.main.bounds.height < 880 ? 32 : 0
    }

    var body: some View {
        ZStack {
            cornerImages

            centerCard
        }
        .frame(maxWidth: .infinity)
        .frame(height: containerHeight)
        .padding(.top, 48)
        .offset(y: extraTopOffset)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.8)
        .onAppear { syncAppeared() }
        .onChange(of: isActive) { syncAppeared() }
    }

    private func syncAppeared() {
        // Damping fraction below 1 gives a slight overshoot, matching the
        // fly-in feel of the other onboarding visuals.
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            appeared = isActive
        }
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
            name: "Image/Onboarding/2-1",
            x: 1,
            y: 1,
            rotation: .degrees(-30),
            scale: 1.8,
            extraOffsetX: 0.12
        ),
        CornerImageConfig(
            name: "Image/Onboarding/2-2",
            x: 1,
            y: -1,
            scale: 1.6,
            extraOffsetX: -0.08
        ),
        CornerImageConfig(
            name: "Image/Onboarding/2-3",
            x: -1,
            y: 1,
            scale: 2.5
        ),
        CornerImageConfig(
            name: "Image/Onboarding/2-4",
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
            // Slightly stronger card shadow for the corner images.
            .shadow(
                color: Color(
                    red: 0.000,
                    green: 0.000,
                    blue: 0.000,
                    opacity: 0.12
                ),
                radius: 8,
                x: 0,
                y: 5
            )
    }

    /// Wider glass card showing a feed nutrition readout.
    private var centerCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Ampas Tahu")
                .font(.custom("PlusJakartaSans-ExtraBold", size: 22))
                .foregroundStyle(AppColor.Primitive.Base.white)

            nutritionRow("Protein", value: "50%", meetsNeed: false)
            nutritionRow("Energi (TDN)", value: "56%", meetsNeed: true)
            nutritionRow("Calcium", value: "12%", meetsNeed: true)
        }
        .padding(AppSpacing.lg)
        .frame(
            width: cardSize.width,
            height: cardSize.height,
            alignment: .topLeading
        )
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

    /// One nutrition row: label on the left, value plus a status symbol on
    /// the right. `meetsNeed` picks a green checkmark or a red cross.
    private func nutritionRow(
        _ label: String,
        value: String,
        meetsNeed: Bool
    ) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Text(label)
                .font(.custom("PlusJakartaSans-Medium", size: 15))
                .foregroundStyle(AppColor.Primitive.Base.white.opacity(0.85))

            Spacer()

            Text(value)
                .font(.custom("PlusJakartaSans-Bold", size: 15))
                .foregroundStyle(AppColor.Primitive.Base.white)

            statusSymbol(meetsNeed: meetsNeed)
        }
    }

    /// Small colored circle with a white mark, drawn as separate circle and
    /// glyph so the mark stays white on both colors.
    private func statusSymbol(meetsNeed: Bool) -> some View {
        ZStack {
            Circle()
                .fill(meetsNeed ? Color.green : Color.red)
            Image(systemName: meetsNeed ? "checkmark" : "xmark")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(AppColor.Primitive.Base.white)
        }
        .frame(width: 18, height: 18)
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
    OnboardingNutritionPlanningView(isActive: true)
        .padding(AppSpacing.massive)
        .background(AppColor.Surface.canvas)
}
