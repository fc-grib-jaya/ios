//
//  GenderForm.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 18/11/26.
//

import SwiftUI

struct GenderForm: View {
    @Binding var genderSapi: CattleGender?
    
    var body: some View {
        VStack {
            Text("Jenis kelamin sapi")
                .font(AppFont.formTitle)
                .foregroundStyle(AppColor.Primitive.Secondary.shade950)
                .multilineTextAlignment(.center)
                .padding(.vertical, AppSpacing.xl)
            
            CenteredFlowLayout(horizontalSpacing: 10, verticalSpacing: 18) {
                ForEach(
                    CattleGender.allCases, id: \.self
                ) { gender in
                    AppRadioButton(
                        LocalizedStringKey(gender.rawValue),
                        value: gender,
                        selection: $genderSapi
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
    @Previewable @State var genderSapi: CattleGender?
    GenderForm(genderSapi: $genderSapi)
}
