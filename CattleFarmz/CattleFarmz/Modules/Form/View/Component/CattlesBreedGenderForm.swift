//
//  CattlesBreedGenderForm.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 16/11/26.
//

import SwiftUI

struct CattlesBreedGenderForm: View {
    @Binding var jenisSapi: CattleBreed?
    @Binding var genderSapi: CattleGender?
    
    @FocusState private var focusedField: Field?
    
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
            
            Spacer()
            
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
            
            Spacer()
        }
        .padding(.horizontal, AppSpacing.md)
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
    }
}

#Preview {
    @Previewable @State var jenisSapi: CattleBreed?
    @Previewable @State var genderSapi: CattleGender?
    
    CattlesBreedGenderForm(jenisSapi: $jenisSapi, genderSapi: $genderSapi)
}
