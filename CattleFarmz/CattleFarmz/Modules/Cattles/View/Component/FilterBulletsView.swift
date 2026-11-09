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
                            isSelected ? AppColor.Text.primary : AppColor.Text.secondary
                        )
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.xs)
                        .background(
                            isSelected
                            ? AppColor.Button.Primary.background.opacity(0.4)
                            : AppColor.Button.Secondary.background.opacity(0.1)
                        )
                        .clipShape(Capsule())
//                        .glassEffect()
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
