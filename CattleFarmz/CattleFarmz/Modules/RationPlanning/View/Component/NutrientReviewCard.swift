import SwiftUI

struct NutrientReviewCard: View {
    let result: RationCalculationResult
    let onShowDetails: () -> Void
    
    private var rows: [NutrientComparison] { NutrientComparison.rows(for: result) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            ForEach(rows) { row in
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(row.name).font(AppFont.headline)
                        Text("\(formattedValue(row.actual, unit: row.unit)) · Referensi \(formattedValue(row.minimum, unit: row.unit))")
                            .font(AppFont.body)
                    }
                    Spacer()
                    Text(row.coverage.map { evaluationNumber($0 * 100, digits: 0) + "%" } ?? "—")
                        .font(AppFont.headline)
                        .padding(AppSpacing.sm)
                        .foregroundStyle(AppColor.Primitive.Neutral.shade950)
                        .background(
                            badgeBackground(for: row.coverage),
                            in: RoundedRectangle(cornerRadius: AppRadius.small)
                        )
                    
                }
                Divider()
            }
            Button(action: onShowDetails) {
                HStack(spacing: AppSpacing.md) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 25))
                        .foregroundStyle(AppColor.Primitive.Neutral.shade400)
                    Text("Lihat detail analisis")
                        .font(AppFont.mediumBody)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(AppColor.Primitive.Neutral.shade400)
                }
            }
            .buttonStyle(.plain)
            


        }
        .evaluationCard()
    }
    private func badgeBackground(for coverage: Double?) -> Color {
        guard let coverage else { return AppColor.Primitive.Neutral.shade100 }
        return coverage >= 1 ? AppColor.Primitive.Primary.shade50 : AppColor.Primitive.Secondary.shade100
    }

    private func formattedValue(_ value: Double?, unit: String) -> String {
        guard let value else { return "Tidak tersedia" }
        let suffix = unit.trimmingCharacters(in: .whitespaces)
        let number = value.formatted(
            .number.locale(Locale(identifier: "id_ID")).precision(.fractionLength(0...2))
        )
        return number + (suffix == "%" ? "%" : " " + suffix)
    }
    
}

#if DEBUG
#Preview {
    NutrientReviewCard(result: RationEvaluationPreviewData.result, onShowDetails: {})
        .padding(AppSpacing.md)
}
#endif
