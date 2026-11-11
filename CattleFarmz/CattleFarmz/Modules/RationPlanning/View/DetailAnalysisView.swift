import SwiftUI

struct DetailAnalysisView: View {
    let result: RationCalculationResult
    var cattleName: String? = nil
    @State private var section = AnalysisSection.adequacy

    var body: some View {
        let nutrients = NutrientComparison.rows(for: result)
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                RationProfileCard(profile: result.profile, cattleName: cattleName)
                AnalysisSectionPicker(selection: $section)
                switch section {
                case .adequacy:
                    NutrientAdequacySummary(nutrients: nutrients)
                    NutrientAdequacyGroup(title: "Energi & protein", nutrients: Array(nutrients.prefix(2)))
                    NutrientAdequacyGroup(title: "Mineral makro", nutrients: Array(nutrients[2..<5]))
                    NutrientAdequacyGroup(title: "Mineral mikro", nutrients: Array(nutrients.suffix(3)))
                    if !result.warnings.isEmpty {
                        messagesCard(title: "Peringatan", messages: result.warnings)
                    }
                    if !result.recommendations.isEmpty {
                        messagesCard(title: "Panduan pemberian pakan", messages: result.recommendations)
                    }
                case .dailyAmount:
                    DailyFeedSummaryCard(result: result)
                    ProteinContributionCard(result: result)
                    FeedProportionsCard(result: result)
                }
            }
            .padding(AppSpacing.Screen.compact)
        }
        .background(AppColor.Surface.canvas)
        .foregroundStyle(AppColor.Text.primary)
        .navigationTitle("Detail analisis")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func messagesCard(title: String, messages: [String]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title).font(AppFont.title)
            ForEach(Array(messages.enumerated()), id: \.offset) { _, message in
                Text(message).font(AppFont.body)
            }
        }
        .evaluationCard()
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        DetailAnalysisView(result: RationEvaluationPreviewData.result, cattleName: "Sapi #00001")
    }
}
#endif
