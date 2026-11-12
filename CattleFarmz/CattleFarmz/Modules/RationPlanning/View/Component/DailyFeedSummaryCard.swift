import SwiftUI

struct DailyFeedSummaryCard: View {
    let result: RationCalculationResult

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Total pemberian / ekor / hari").font(AppFont.headline)
            Text("\(evaluationNumber(result.kilogramsPerAnimalPerDay)) kg").font(AppFont.largeTitle)
            Divider()
            LabeledContent("Bahan kering dari total tersebut", value: "Data belum tersedia")
                .font(AppFont.caption)
            HStack(spacing: AppSpacing.xs) {
                metric("Protein kasar", value: result.proteinKilogramsPerAnimalPerDay)
                metric("TDN", value: result.tdnKilogramsPerAnimalPerDay)
            }
        }
        .evaluationCard()
    }

    private func metric(_ title: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title).font(AppFont.caption)
            Text(value.formatted(.number.locale(Locale(identifier: "id_ID")).precision(.fractionLength(3))))
                .font(AppFont.title) + Text(" kg/hari").font(AppFont.caption)
        }
        .padding(AppSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(AppColor.Primitive.Primary.shade800)
        .background(AppColor.Surface.inset, in: RoundedRectangle(cornerRadius: AppRadius.large))
        .overlay { RoundedRectangle(cornerRadius: AppRadius.large).strokeBorder(AppColor.Border.subtle) }
    }
}

#if DEBUG
#Preview {
    DailyFeedSummaryCard(result: RationEvaluationPreviewData.result).padding(AppSpacing.md)
}
#endif
