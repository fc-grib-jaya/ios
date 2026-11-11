import SwiftUI

enum AnalysisSection: String, CaseIterable, Identifiable {
    case adequacy = "Kecukupan"
    case dailyAmount = "Jumlah harian"
    var id: Self { self }
}

struct AnalysisSectionPicker: UIViewRepresentable {
    @Binding var selection: AnalysisSection

    func makeUIView(context: Context) -> UISegmentedControl {
        let control = UISegmentedControl(items: AnalysisSection.allCases.map(\.rawValue))
        control.selectedSegmentTintColor = UIColor(AppColor.Primitive.Primary.shade500)
        control.setTitleTextAttributes([.foregroundColor: UIColor(AppColor.Button.Primary.foreground)], for: .selected)
        control.addTarget(context.coordinator, action: #selector(Coordinator.select(_:)), for: .valueChanged)
        control.accessibilityLabel = "Bagian analisis"
        return control
    }

    func updateUIView(_ control: UISegmentedControl, context: Context) {
        context.coordinator.selection = $selection
        control.selectedSegmentIndex = AnalysisSection.allCases.firstIndex(of: selection) ?? 0
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UISegmentedControl, context: Context) -> CGSize? {
        CGSize(width: proposal.width ?? uiView.intrinsicContentSize.width, height: max(44, uiView.intrinsicContentSize.height))
    }

    func makeCoordinator() -> Coordinator { Coordinator($selection) }

    final class Coordinator: NSObject {
        var selection: Binding<AnalysisSection>
        init(_ selection: Binding<AnalysisSection>) { self.selection = selection }

        @objc func select(_ control: UISegmentedControl) {
            let sections = AnalysisSection.allCases
            guard sections.indices.contains(control.selectedSegmentIndex) else { return }
            selection.wrappedValue = sections[control.selectedSegmentIndex]
        }
    }
}

#Preview {
    @Previewable @State var section = AnalysisSection.adequacy
    AnalysisSectionPicker(selection: $section).padding(AppSpacing.md)
}
