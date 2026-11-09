//
//  ToastContent.swift
//  CattleFarmz
//

import SwiftUI

/// The circle and message inside the toast capsule.
///
/// The text width is fixed by `ToastLayout`, so expanding the container moves
/// the circle left through normal layout instead of an animated offset.
struct ToastContent: View {
    let item: ToastItem
    let configuration: ToastConfiguration
    let textWidth: CGFloat
    let contentOpacity: Double
    let iconScale: CGFloat

    var body: some View {
        HStack(spacing: configuration.contentSpacing) {
            ZStack {
                Circle()
                    .fill(item.accentColor)

                Image(systemName: item.icon)
                    .font(.system(size: configuration.iconSize, weight: .semibold))
                    .foregroundStyle(AppColor.Primitive.Base.white)
                    .opacity(contentOpacity)
                    .scaleEffect(iconScale)
            }
            .frame(width: configuration.circleSize, height: configuration.circleSize)
            .accessibilityHidden(true)

            Text(item.message)
                .font(AppFont.mediumSubheadline)
                .foregroundStyle(AppColor.Text.primary)
                .multilineTextAlignment(.leading)
                .frame(width: max(0, textWidth), alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(contentOpacity)
        }
    }
}

#Preview {
    ToastContent(
        item: ToastItem(message: "Your changes have been saved"),
        configuration: ToastConfiguration(),
        textWidth: 244,
        contentOpacity: 1,
        iconScale: 1
    )
    .padding()
}
