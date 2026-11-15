//
//  OnboardingWeightEstimationView.swift
//  CattleFarmz
//

import SwiftUI

/// Custom content for the weight-estimation onboarding screen: two stacked
/// glass cards overlapping diagonally, the gray one offset toward the
/// bottom-right corner.
struct OnboardingWeightEstimationView: View {
    /// Side length of both square glass cards.
    private let cardSize: CGFloat = 209
    private let frontAngle = Angle.degrees(-4)
    private let backAngle = Angle.degrees(4)

    var body: some View {
        ZStack(alignment: .topLeading) {
            frontCard

            backCard
                // Half-overlap so the second card sits at the
                // bottom-right corner, stacked diagonally.
                .offset(x: cardSize - 64, y: cardSize - 48)
        }
    }

    /// The image card with the LiDAR label. Content, clip mask, and glass
    /// shape all share the same rotation so they stay aligned.
    private var frontCard: some View {
        Image("1-1")
            .resizable()
            .scaledToFill()
            .frame(width: cardSize, height: cardSize)
            // Zooms the fill further so more of the image is cropped by the
            // container, keeping the masked look. Tune the factor to taste.
            .scaleEffect(1.5)
            .offset(x: -15, y: 52)
            .overlay(alignment: .top) {
                Label(
                    "Pindai dengan LiDAR",
                    systemImage: "square.2.layers.3d.top.filled"
                )
                .font(.custom("PlusJakartaSans-Bold", size: 13))
                .foregroundStyle(AppColor.Primitive.Base.white)
                .padding(.top, AppSpacing.sm)
            }
            // Rotate before clipping so the mask turns with the content.
            .rotationEffect(frontAngle)
            .clipShape(
                RotatedRoundedRectangle(cornerRadius: 28, angle: frontAngle)
            )
            .glassEffect(
                .regular.tint(AppColor.Primitive.Primary.shade500),
                in: RotatedRoundedRectangle(cornerRadius: 28, angle: frontAngle)
            )
            // Same card shadow as the home cattle cards.
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

    /// Empty glass card in front of the image card.
    private var backCard: some View {
        Color.clear
            .frame(width: cardSize, height: cardSize)
            .glassEffect(
                .regular.tint(Color.gray.opacity(0.5)),
                in: RotatedRoundedRectangle(cornerRadius: 28, angle: backAngle)
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

/// A rounded rectangle rotated about its center, usable as a glass effect
/// shape so the glass rotates together with the card content.
private struct RotatedRoundedRectangle: Shape {
    var cornerRadius: CGFloat
    var angle: Angle

    func path(in rect: CGRect) -> Path {
        let base = Path(
            roundedRect: rect,
            cornerRadius: cornerRadius,
            style: .continuous
        )
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let transform = CGAffineTransform(translationX: center.x, y: center.y)
            .rotated(by: angle.radians)
            .translatedBy(x: -center.x, y: -center.y)
        return base.applying(transform)
    }
}

#Preview {
    OnboardingWeightEstimationView()
        .padding(AppSpacing.massive)
        .background(AppColor.Surface.canvas)
}
