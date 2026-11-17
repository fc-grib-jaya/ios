import SwiftUI

struct RationRecommendationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: RationRecommendationViewModel
    let onApply: (RationCalculationResult) -> Void

    init(viewModel: RationRecommendationViewModel, onApply: @escaping (RationCalculationResult) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onApply = onApply
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                RationReplacementCard(viewModel: viewModel)
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    Text("Apa dampaknya?").font(AppFont.title)
                    if let scenario = viewModel.scenario {
                        let before = NutrientComparison.rows(for: viewModel.selected.before)
                        let after = NutrientComparison.rows(for: scenario)
                        ForEach([1, 0], id: \.self) { index in
                            NutrientScenarioCard(before: before[index], after: after[index])
                        }
                        Divider()
                        RationChangesTable(recommendation: viewModel.selected, scenario: scenario)

                    } else {
                        Text("Isi porsi yang valid untuk melihat dampaknya.")
                            .font(AppFont.body).foregroundStyle(AppColor.Text.secondary)
                    }
                }
                .evaluationCard()
            }
            .padding(AppSpacing.Screen.compact)
        }
        .background(AppColor.Surface.canvas)
        .foregroundStyle(AppColor.Text.primary)
        .navigationTitle("Saran perbaikan nutrisi")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button {
                guard let scenario = viewModel.scenario else { return }
                onApply(scenario)
                dismiss()
            } label: {
                Text("Simpan saran perbaikan nutrisi")
            }
            .appButtonStyle(.primary)
            .disabled(viewModel.scenario == nil)
            .padding(AppSpacing.Screen.compact)
            .background(AppColor.Surface.canvas)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        RationRecommendationView(viewModel: RationRecommendationPreviewData.viewModel(), onApply: { _ in })
    }
}
#endif
