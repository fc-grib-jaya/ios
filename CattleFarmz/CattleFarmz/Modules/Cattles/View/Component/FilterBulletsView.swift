//
//  FilterBulletsView.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 05/11/26.
//

import SwiftUI

struct FilterBulletsView: View {
    let options: [String]
    @Binding var selectedOptions: Set<String>

    var body: some View {
        VStack(alignment: .leading) {
            FlowLayout {
                ForEach(options, id: \.self) { option in
                    let isSelected = selectedOptions.contains(option)

                    Text(option)
                        .font(isSelected ? AppFont.mediumBody : AppFont.body)
                        .foregroundStyle(
                            isSelected ? AppColor.primary : AppColor.textSecondary
                        )
                        .padding(.horizontal, AppSpacing.medium)
                        .padding(.vertical, AppSpacing.xm)
                        .background(
                            isSelected
                            ? AppColor.primary.opacity(0.4)
                                : AppColor.primary.opacity(0.1)
                        )
                        .clipShape(Capsule())
                        .glassEffect()
                        .onTapGesture {
                            Haptics.selectionChanged()
                            if isSelected {
                                selectedOptions.remove(option)
                            } else {
                                selectedOptions.insert(option)
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedOptions: Set<String> = ["Brahman"]
    FilterBulletsView(
        options: CattleBreed.allCases.map(\.rawValue),
        selectedOptions: $selectedOptions
    )
}
