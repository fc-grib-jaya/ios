//
//  GlassPrimaryButton.swift
//  CattleFarmz
//

import SwiftUI

/// Primary action button rendered as a Liquid Glass capsule tinted with the
/// primary action color.
///
/// The glass effect requires iOS 26. On earlier versions the button falls back
/// to a solid brand-colored capsule.
struct GlassPrimaryButton: View {
    private let title: String
    private let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        if #available(iOS 26.0, *) {
            button
                .glassEffect(.regular.tint(AppColor.Button.Primary.background).interactive(), in: .capsule)
        } else {
            button
                .background(AppColor.Button.Primary.background, in: .capsule)
        }
    }

    private var button: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.headline)
                .foregroundStyle(AppColor.Button.Primary.foreground)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.vertical, AppSpacing.md)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.orange, .pink, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        GlassPrimaryButton("Start Scan", action: {})
    }
}
