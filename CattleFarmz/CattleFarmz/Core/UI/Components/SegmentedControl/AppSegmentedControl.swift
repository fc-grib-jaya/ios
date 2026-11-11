import SwiftUI
import UIKit

/// One reusable native segmented picker. The caller owns the selection.
struct AppSegmentedControl<Selection: Hashable, SegmentLabel: View>: View {
    private let title: LocalizedStringKey
    private let options: [Selection]
    @Binding private var selection: Selection
    private let label: (Selection) -> SegmentLabel

    init(
        _ title: LocalizedStringKey,
        options: [Selection],
        selection: Binding<Selection>,
        @ViewBuilder label: @escaping (Selection) -> SegmentLabel
    ) {
        precondition(!options.isEmpty && Set(options).count == options.count)
        _ = SegmentedControlAppearance.configureOnce
        self.title = title
        self.options = options
        self._selection = selection
        self.label = label
    }

    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(options, id: \.self) { option in
                label(option).tag(option)
            }
        }
        .pickerStyle(.segmented)
        .controlSize(.large)
        .labelsHidden()
        .accessibilityLabel(Text(title))
    }
}

// Configure before the native Picker is created, including in previews.
// UIAppearance applies to all native segmented controls in this app.
@MainActor
private enum SegmentedControlAppearance {
    static let configureOnce: Void = {
        let primary = UIColor(AppColor.Primitive.Primary.shade400)
        let white = UIColor(AppColor.Primitive.Base.white)
        let segmented = UISegmentedControl.appearance()
        let font = UIFont.systemFont(ofSize: 15, weight: .regular)

        segmented.selectedSegmentTintColor = primary
        segmented.backgroundColor = primary.withAlphaComponent(0.12)
        segmented.setTitleTextAttributes(
            [.foregroundColor: primary, .font: font], for: .normal
        )
        segmented.setTitleTextAttributes(
            [.foregroundColor: white, .font: font], for: .selected
        )
    }()
}

#Preview {
    @Previewable @State var selected = "Karkas"
    AppSegmentedControl(
        "Bagian sapi",
        options: ["Karkas", "Pakan"],
        selection: $selected
    ) { Text($0) }
    .padding()
}
