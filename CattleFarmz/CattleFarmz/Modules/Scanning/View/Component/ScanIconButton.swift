import SwiftUI

/// Shared 44-point controls for the scanning screens.
struct ScanIconButton: View {
    enum Style: Equatable {
        case material
        case primary
        case disabled

        var background: AnyShapeStyle {
            switch self {
            case .material: AnyShapeStyle(.ultraThinMaterial)
            case .primary: AnyShapeStyle(AppColor.Primitive.Primary.shade500)
            case .disabled: AnyShapeStyle(AppColor.Primitive.Neutral.shade300)
            }
        }

        var foreground: Color {
            switch self {
            case .material: AppColor.Primitive.Neutral.shade950
            case .primary: AppColor.Primitive.Neutral.shade50
            case .disabled: AppColor.Primitive.Neutral.shade600
            }
        }
    }

    let systemImage: String
    let accessibilityLabel: String
    var style: Style = .material
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .frame(width: 44, height: 44)
                .background(style.background, in: Circle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(style.foreground)
        .accessibilityLabel(accessibilityLabel)
        .disabled(style == .disabled)
    }
}

#Preview("Button styles", traits: .sizeThatFitsLayout) {
    HStack(spacing: AppSpacing.lg) {
        ScanIconButton(systemImage: "xmark", accessibilityLabel: "Tutup kamera") {}
        ScanIconButton(systemImage: "chevron.left", accessibilityLabel: "Kembali") {}
        ScanIconButton(systemImage: "questionmark.circle", accessibilityLabel: "Petunjuk", style: .primary) {}
        ScanIconButton(systemImage: "checkmark", accessibilityLabel: "Lanjut", style: .primary) {}
        ScanIconButton(systemImage: "checkmark", accessibilityLabel: "Belum dapat lanjut", style: .disabled) {}
    }
    .padding(AppSpacing.lg)
    .background(AppColor.Surface.canvas)
}
