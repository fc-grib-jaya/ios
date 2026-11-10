import SwiftUI

struct AppRadioButtonStyle: ButtonStyle {
    let isSelected: Bool
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: AppRadius.full)
        let isPressed = configuration.isPressed && isEnabled
        let foreground = isSelected ? AppColor.Button.Primary.background : AppColor.Text.primary
        let background = (isPressed || isSelected) ? AppColor.Primitive.Primary.shade100 : AppColor.Surface.canvas

        configuration.label
            .font(AppFont.body)
            .foregroundStyle(foreground)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background {
                shape.fill(background.shadow(.inner(color: .white.opacity(0.12), radius: 6, x: 0, y: 2)))
            }
            .overlay {
                if !isSelected {
                    shape.strokeBorder(AppColor.Border.default, lineWidth: 1)
                        .allowsHitTesting(false)
                }
            }
            .contentShape(shape)
            .opacity(isEnabled ? 1 : 0.45)
    }
}
