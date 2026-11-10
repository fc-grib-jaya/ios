import SwiftUI

/// Bind every option in a group to the same selection to allow exactly one choice.
/// A nil selection represents a group the user has not answered yet.
struct AppRadioButton<Value: Hashable>: View {
    let title: LocalizedStringKey
    let value: Value
    @Binding var selection: Value?

    init(_ title: LocalizedStringKey, value: Value, selection: Binding<Value?>) {
        self.title = title
        self.value = value
        self._selection = selection
    }

    private var isSelected: Bool { selection == value }

    var body: some View {
        Button {
            selection = value
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .accessibilityHidden(true)
                Text(title)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
        }
        .buttonStyle(AppRadioButtonStyle(isSelected: isSelected))
        .accessibilityLabel(Text(title))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Radio buttons · Light") {
    @Previewable @State var selection: String? = "male"
    VStack(spacing: AppSpacing.md) {
        AppRadioButton("Jantan", value: "male", selection: $selection)
        AppRadioButton("Betina", value: "female", selection: $selection)
        AppRadioButton("Selected · disabled", value: "male", selection: .constant("male"))
            .disabled(true)
        AppRadioButton("Unselected · disabled", value: "female", selection: .constant("male"))
            .disabled(true)
    }.padding().preferredColorScheme(.light)
}

#Preview("Radio buttons · Dark") {
    @Previewable @State var selection: String?
    VStack(spacing: AppSpacing.md) {
        AppRadioButton("Jantan", value: "male", selection: $selection)
        AppRadioButton("Betina", value: "female", selection: $selection)
    }.padding().preferredColorScheme(.dark)
}
