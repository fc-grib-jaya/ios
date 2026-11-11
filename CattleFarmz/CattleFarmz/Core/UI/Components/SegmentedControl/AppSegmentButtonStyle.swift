import SwiftUI

/// Internal rendering for each segment. Selection remains owned by the binding.
struct AppSegmentButtonStyle: ButtonStyle {
    let isSelected: Bool
    let style: AppSegmentedControlStyle
    let selectionNamespace: Namespace.ID?
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: max(0, style.segmentCornerRadius))
        configuration.label
            .font(style.font)
            .multilineTextAlignment(.center)
            .foregroundStyle(isSelected ? style.selectedForegroundColor : style.foregroundColor)
            .padding(style.segmentPadding)
            .frame(maxWidth: style.fillsWidth ? .infinity : nil, minHeight: max(44, style.minimumHeight))
            .background {
                if isSelected {
                    let indicator = shape.fill(style.selectedBackgroundColor)
                        .overlay {
                            if style.selectedBorderWidth > 0 {
                                shape.strokeBorder(style.selectedBorderColor, lineWidth: style.selectedBorderWidth)
                            }
                        }
                        .allowsHitTesting(false)

                    // Each control owns a namespace so indicators never move between groups.
                    if let selectionNamespace {
                        indicator
                            .matchedGeometryEffect(id: "selection", in: selectionNamespace)
                            .transition(.identity)
                    } else {
                        indicator
                    }
                }
            }
            .contentShape(shape)
            .opacity(!isEnabled ? style.disabledOpacity : configuration.isPressed ? style.pressedOpacity : 1)
    }
}
