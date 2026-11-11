import SwiftUI

struct NutritionResultCard: View {
    let below: Int
    let unknown: Int
    let total: Int

    private var complete: Bool { below == 0 && unknown == 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.sm) {
                Text(complete ? "Semua minimum referensi terpenuhi." : "Ada yang perlu ditinjau kembali.")
                    .font(AppFont.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(complete ? "NutritionCheck" : "NutritionWarn")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 92)
                    .accessibilityHidden(true)
            }
            if below > 0 {
                Text("\(below) dari \(total) nutrisi pakan berada **di bawah** nilai minimum referensi.")
            } else if complete {
                Text("Seluruh \(total) nutrisi mencapai nilai minimum referensi.")
            }
            if unknown > 0 {
                Text("\(unknown) nutrisi belum dapat dibandingkan karena data belum lengkap.")
            }
        }
        .font(AppFont.body)
        .padding(AppSpacing.xxl)
        .foregroundStyle(AppColor.Primitive.Neutral.shade950)
        .background(complete ? AppColor.Primitive.Primary.shade50 : AppColor.Primitive.Secondary.shade50,
                    in: RoundedRectangle(cornerRadius: AppRadius.large))
    }
}

#Preview("Perlu ditinjau") {
    NutritionResultCard(below: 4, unknown: 0, total: 8)
        .padding(AppSpacing.md)
}

#Preview("Minimum terpenuhi") {
    NutritionResultCard(below: 0, unknown: 0, total: 8)
        .padding(AppSpacing.md)
}

#Preview("Data belum lengkap") {
    NutritionResultCard(below: 0, unknown: 2, total: 8)
        .padding(AppSpacing.md)
}
