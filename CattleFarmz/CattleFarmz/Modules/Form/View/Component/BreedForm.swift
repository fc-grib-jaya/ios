//
//  BreedForm.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 18/11/26.
//

import SwiftUI

struct BreedForm: View {
    @Binding var jenisSapi: CattleBreed?
    
    var body: some View {
        VStack {
            Text("Jenis sapi")
                .font(AppFont.formTitle)
                .foregroundStyle(AppColor.Primitive.Secondary.shade950)
                .multilineTextAlignment(.center)
                .padding(.vertical, AppSpacing.xl)
            
            CenteredFlowLayout(horizontalSpacing: 10, verticalSpacing: 18) {
                ForEach(
                    CattleBreed.allCases.sorted { $0.rawValue < $1.rawValue },
                    id: \.self
                ) { breed in
                    AppRadioButton(
                        LocalizedStringKey(breed.rawValue),
                        value: breed,
                        selection: $jenisSapi
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.xxs)
        }
        .padding(.horizontal, AppSpacing.md)
    }
}

#Preview {
    @Previewable @State var jenisSapi: CattleBreed?
    BreedForm(jenisSapi: $jenisSapi)
}
