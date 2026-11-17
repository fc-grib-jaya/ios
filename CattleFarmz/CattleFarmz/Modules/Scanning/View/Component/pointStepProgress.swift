//
//  pointStepProgress.swift
//  CattleFarmz
//
//  Created by Salman on 16/11/26.
//

import SwiftUI

struct PointStepProgress: View {
    let steps: [MeasurementGuideStep]
    let activeID: String?
    let completedIDs: Set<String>
    let onSelect: (Int) -> Void

    var body: some View {
        HStack(spacing: AppSpacing.xxs) {
            ForEach(steps.indices, id: \.self) { index in
                let step = steps[index]
                let isActive = activeID == step.id
                let isCompleted = completedIDs.contains(step.id)

                Button {
                    onSelect(index)
                } label: {
                    HStack(spacing: AppSpacing.xxs) {
                        if isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppColor.Primitive.Primary.shade500)
                        }
                        Text(step.label)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .font(AppFont.caption)
                    .foregroundStyle(isActive ? AppColor.Primitive.Neutral.shade900 : AppColor.Primitive.Neutral.shade50)
                    .padding(.horizontal, AppSpacing.xs)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(isActive ? AppColor.Primitive.Primary.shade200 : .clear, in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(step.label)
                .accessibilityValue(isCompleted ? "Sudah dikonfirmasi" : "Belum dikonfirmasi")
                .accessibilityAddTraits(isActive ? .isSelected : [])
            }
        }
        .padding(AppSpacing.xxs)
        .background(.ultraThinMaterial, in: Capsule())
    }
}

#Preview("Select points", traits: .fixedLayout(width: 650, height: 120)) {
    @Previewable @State var selectedIndex = 1
    let steps = MeasurementGuideStep.steps

    PointStepProgress(
        steps: steps,
        activeID: steps[selectedIndex].id,
        completedIDs: [steps[0].id, steps[1].id]
    ) { selectedIndex = $0 }
    .padding()
}
