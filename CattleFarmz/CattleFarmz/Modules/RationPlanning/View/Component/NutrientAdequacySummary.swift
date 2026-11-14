import SwiftUI

struct NutrientAdequacySummary: View {
    let nutrients: [NutrientComparison]

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            countCard(
                count: nutrients.filter { ($0.coverage ?? 0) >= 1 }.count,
                title: "Memenuhi minimum",
                background: AppColor.Primitive.Primary.shade50,
                foreground: AppColor.Primitive.Primary.shade800
            )
            countCard(
                count: nutrients.filter { $0.coverage.map { $0 < 1 } == true }.count,
                title: "Di bawah referensi",
                background: AppColor.Primitive.Secondary.shade50,
                foreground: AppColor.Primitive.Secondary.shade900
            )
        }
        let unknown = nutrients.filter { $0.coverage == nil }.count
        if unknown > 0 {
            Text("\(unknown) nutrisi belum memiliki data perbandingan.")
                .font(AppFont.caption)
                .foregroundStyle(AppColor.Text.secondary)
        }
    }

    private func countCard(count: Int, title: String, background: Color, foreground: Color) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Text(count.formatted()).font(AppFont.largeTitle)
            Text(title).font(AppFont.caption)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.md)
        .foregroundStyle(foreground)
        .background(background, in: RoundedRectangle(cornerRadius: AppRadius.large))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.large).strokeBorder(AppColor.Border.subtle)
        }
    }
}

#if DEBUG
#Preview {
    NutrientAdequacySummary(nutrients: NutrientComparison.rows(for: RationEvaluationPreviewData.result))
        .padding(AppSpacing.md)
}
#endif
