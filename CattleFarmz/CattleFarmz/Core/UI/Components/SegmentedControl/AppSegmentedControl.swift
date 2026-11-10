import SwiftUI

/// Options must be unique. Pass one binding for the group; tapping the selected
/// option keeps it selected. Labels may be Text or Label, with meaningful accessible text.
struct AppSegmentedControl<Selection: Hashable, Label: View>: View {
    private let title: LocalizedStringKey
    private let options: [Selection]
    @Binding private var selection: Selection
    private let style: AppSegmentedControlStyle
    private let isOptionEnabled: (Selection) -> Bool
    private let label: (Selection) -> Label
    @Namespace private var selectionNamespace

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    init(
        _ title: LocalizedStringKey,
        options: [Selection],
        selection: Binding<Selection>,
        style: AppSegmentedControlStyle = .init(),
        isOptionEnabled: @escaping (Selection) -> Bool = { _ in true },
        @ViewBuilder label: @escaping (Selection) -> Label
    ) {
        precondition(Set(options).count == options.count, "Segment options must be unique.")
        self.title = title
        self.options = options
        self._selection = selection
        self.style = style
        self.isOptionEnabled = isOptionEnabled
        self.label = label
    }

    var body: some View {
        // Large accessibility text gets a vertical layout without truncating labels.
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: max(0, style.spacing)))
            : AnyLayout(HStackLayout(spacing: max(0, style.spacing)))
        let shape = RoundedRectangle(cornerRadius: max(0, style.cornerRadius))

        layout {
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    HStack(spacing: AppSpacing.xxs) {
                        label(option)
                        if differentiateWithoutColor && option == selection {
                            Image(systemName: "checkmark").accessibilityHidden(true)
                        }
                    }
                }
                .buttonStyle(AppSegmentButtonStyle(
                    isSelected: option == selection,
                    style: style,
                    selectionNamespace: reduceMotion ? nil : selectionNamespace
                ))
                .disabled(!isOptionEnabled(option))
                .accessibilityAddTraits(option == selection ? .isSelected : [])
            }
        }
        .padding(max(0, style.containerPadding))
        .background(style.backgroundColor, in: shape)
        .overlay {
            if style.borderWidth > 0 {
                shape.strokeBorder(style.borderColor, lineWidth: style.borderWidth)
                    .allowsHitTesting(false)
            }
        }
        .animation(reduceMotion ? nil : style.selectionAnimation, value: selection)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(title))
    }
}

#Preview("Segments · Light") {
    @Previewable @State var selected = "Manual"
    VStack(spacing: AppSpacing.lg) {
        AppSegmentedControl("Mode", options: ["Manual", "Camera"], selection: $selected) { Text($0) }
        AppSegmentedControl(
            "Custom mode", options: ["Manual", "Camera"], selection: $selected,
            style: .init(selectedBackgroundColor: .orange, selectedForegroundColor: .black,
                         spacing: 8, containerPadding: 8, cornerRadius: 24)
        ) { Text($0) }
        AppSegmentedControl("Disabled", options: ["Manual", "Camera"], selection: $selected) { Text($0) }
            .disabled(true)
        AppSegmentedControl("Unavailable camera", options: ["Manual", "Camera"], selection: $selected,
                            isOptionEnabled: { $0 != "Camera" }) { Text($0) }
    }.padding().preferredColorScheme(.light)
}

#Preview("Segments · Accessibility Dark") {
    @Previewable @State var selected = "Photo"
    AppSegmentedControl("Display", options: ["Photo", "Depth", "Photo and depth"], selection: $selected) { Text($0) }
        .padding().preferredColorScheme(.dark).dynamicTypeSize(.accessibility3)
}
