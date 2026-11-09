//
//  OnboardingActionButton.swift
//  CattleFarmz
//

import SwiftUI

/// Full-width Liquid Glass action button used by the onboarding screens.
///
/// The visual is intentionally identical to the add-cattle button on Home.
struct OnboardingActionButton: View {
    private let title: String
    private let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.body)
                .foregroundStyle(AppColor.Text.primary)
                .padding(.vertical, AppSpacing.xs)
                .frame(maxWidth: .infinity)
                .glassEffect(.regular.tint(AppColor.Primitive.Primary.shade500))
        }
    }
}

#Preview {
    OnboardingActionButton("Lanjut", action: {})
        .padding(.horizontal, AppSpacing.md)
}
