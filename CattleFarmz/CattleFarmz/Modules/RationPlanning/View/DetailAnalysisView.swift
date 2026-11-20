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
                AppSegmentedControl(
                    "Bagian analisis",
                    options: AnalysisSection.allCases,
                    selection: $section
                ) { option in
                    Text(option.rawValue)
                }
                .frame(minHeight: 44)
                switch section {
                case .adequacy:
//                    NutrientAdequacySummary(nutrients: nutrients)
                    NutrientAdequacyGroup(title: "Energi & protein", nutrients: Array(nutrients.prefix(2)))
                    
                    mineralContentCard
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
    
    private var mineralContentCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Kandungan mineral")
                    .font(AppFont.title)

                Text("Rincian mineral makro dan mikro")
                    .font(AppFont.body)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text("Mineral makro")
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.Primitive.Neutral.shade400)
                    .padding(.bottom, AppSpacing.sm)

                mineralRow(
                    "Kalsium",
                    value: result.nutrients.calciumPercent,
                    unit: "%"
                )

                mineralRow(
                    "Fosfor",
                    value: result.nutrients.phosphorusPercent,
                    unit: "%"
                )

                mineralRow(
                    "Magnesium",
                    value: result.nutrients.magnesiumPercent,
                    unit: "%"
                )
            }

            VStack(alignment: .leading, spacing: 0) {
                Text("Mineral mikro")
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.Primitive.Neutral.shade400)
                    .padding(.bottom, AppSpacing.sm)

                mineralRow(
                    "Zat besi",
                    value: result.nutrients.ironPPM,
                    unit: "mg/kg"
                )

                mineralRow(
                    "Tembaga",
                    value: result.nutrients.copperPPM,
                    unit: "mg/kg"
                )

                mineralRow(
                    "Zinc",
                    value: result.nutrients.zincPPM,
                    unit: "mg/kg"
                )
            }
        }
        .evaluationCard()
    }

    private func mineralRow(
        _ title: String,
        value: Double?,
        unit: String
    ) -> some View {
        let formattedValue = value.map {
            evaluationNumber($0, digits: 2)
                + (unit == "%" ? "%" : " \(unit)")
        } ?? "Tidak tersedia"

        return VStack(spacing: 0) {
            Divider()

            LabeledContent {
                Text(formattedValue)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.Text.primary)
                    .multilineTextAlignment(.trailing)
            } label: {
                Text(title)
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.Text.primary)
            }
            .padding(.vertical, AppSpacing.sm)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        DetailAnalysisView(result: RationEvaluationPreviewData.result, cattleName: "Sapi #00001")
    }
}
#endif
