import SwiftUI

struct NutrientBulletChart: View {
    let coverage: Double?
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppColor.Primitive.Neutral.shade300)
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(color)
                            .frame(width: geometry.size.width * fillFraction)
                    }
                    .clipShape(Capsule())
                Rectangle()
                    .fill(AppColor.Text.secondary)
                    .frame(width: AppSpacing.xxxs, height: AppSpacing.md)
                    .offset(x: geometry.size.width * (100.0 / 150.0) - AppSpacing.xxxs / 2)
            }
            .frame(height: AppSpacing.xs)
            .frame(maxHeight: .infinity)
        }
        .frame(height: AppSpacing.md)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Kecukupan nutrisi")
        .accessibilityValue(coverage.map { evaluationNumber($0 * 100) + " persen, maksimum bar 150 persen" } ?? "Data belum tersedia")
    }

    private var fillFraction: Double {
        guard let coverage, coverage.isFinite else { return 0 }
        return min(max(coverage / 1.5, 0), 1)
    }
}

#Preview("Skala 150 persen") {
    VStack(spacing: AppSpacing.md) {
        NutrientBulletChart(coverage: 0.95, color: AppColor.Primitive.Secondary.shade600)
        NutrientBulletChart(coverage: 1, color: AppColor.Primitive.Primary.shade500)
        NutrientBulletChart(coverage: 1.5, color: AppColor.Primitive.Primary.shade500)
        NutrientBulletChart(coverage: 2, color: AppColor.Primitive.Primary.shade500)
        NutrientBulletChart(coverage: nil, color: AppColor.Text.secondary)
    }
    .padding(AppSpacing.md)
}
