import SwiftUI

/// Shared appearance for native Buttons, including custom labels and system roles.
struct AppButtonStyle: ButtonStyle {
    let variant: AppButtonVariant

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed && isEnabled
        let shape = Capsule()

        let label = configuration.label
            .font(AppFont.body)
            .foregroundStyle(foregroundColor(isPressed: isPressed))
            .padding(.horizontal, AppSpacing.Button.horizontal)
            .padding(.vertical, AppSpacing.md)
            .frame(maxWidth: .infinity)
            .contentShape(shape)

        Group {
            if variant == .text {
                // A text button has neither glass background nor border, even when disabled.
                label
            } else {
                label
                    .glassEffect(.regular.tint(backgroundColor(isPressed: isPressed)), in: shape)
                    .overlay {
                        // White preserves the underlying glass in multiply blending;
                        // only the native inner shadow darkens its inside edge.
                        shape.fill(.white.shadow(.inner(color: .white.opacity(0.18), radius: 6, x: 0, y: 2)))
                            .blendMode(.multiply)
                            .allowsHitTesting(false)
                    }
                    .overlay {
                        if variant == .primary {
                            shape.strokeBorder(AppColor.Primitive.Primary.shade400, lineWidth: 0.5)
                                .allowsHitTesting(false)
                        }
                    }
            }
        }
        .opacity(isEnabled ? 1 : 0.45)
    }

    private func foregroundColor(isPressed: Bool) -> Color {
        switch variant {
        case .primary:
            isPressed ? AppColor.Button.Primary.pressedForeground : AppColor.Button.Primary.foreground
        case .secondary, .text:
            isPressed ? AppColor.Button.Secondary.pressedForeground : AppColor.Primitive.Primary.shade500
        }
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        switch variant {
        case .primary:
            isPressed ? AppColor.Button.Primary.pressedBackground : AppColor.Button.Primary.background
        case .secondary:
            isPressed ? AppColor.Button.Secondary.pressedBackground : AppColor.Primitive.Primary.shade100
        case .text:
            .clear
        }
    }
}

extension View {
    func appButtonStyle(_ variant: AppButtonVariant = .primary) -> some View {
        buttonStyle(AppButtonStyle(variant: variant))
    }
}

#Preview("Button styles · Light") {
     VStack(spacing: AppSpacing.md) {
        ForEach(AppButtonVariant.allCases, id: \.self) { variant in
            Button("Enabled: \(String(describing: variant))") {}
                .appButtonStyle(variant)
            Button("Disabled: \(String(describing: variant))") {}
                .appButtonStyle(variant)
                .disabled(true)
        }
        Button("Add cattle", systemImage: "plus") {}
            .appButtonStyle()
    }.padding().preferredColorScheme(.light)
    
}

#Preview("Button styles · Dark") {
    VStack(spacing: AppSpacing.md) {
        ForEach(AppButtonVariant.allCases, id: \.self) { variant in
            Button("Enabled: \(String(describing: variant))") {}
                .appButtonStyle(variant)
            Button("Disabled: \(String(describing: variant))") {}
                .appButtonStyle(variant)
                .disabled(true)
        }
    }.padding().preferredColorScheme(.dark)
}
