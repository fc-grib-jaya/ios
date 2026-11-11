import SwiftUI

extension View {
    func evaluationCard() -> some View {
        padding(AppSpacing.Card.compact)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: AppRadius.large)
                    .fill(AppColor.Card.background)
                    .shadow(color: AppColor.Primitive.Neutral.shade950.opacity(0.1), radius: 5, y: 2)
            }
    }
}

func evaluationNumber(_ value: Double, digits: Int = 2) -> String {
    value.formatted(.number.locale(Locale(identifier: "id_ID")).precision(.fractionLength(0...digits)))
}
