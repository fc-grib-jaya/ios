//
//  SecondPageForm.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 19/11/26.
//

import SwiftUI

struct SecondPageForm: View {
    @Binding var cattleBreed: CattleBreed?
    @Binding var cattleGender: CattleGender?
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                LinearGradient(
                    colors: [
                        AppColor.Primitive.Secondary.shade100,
                        AppColor.Surface.canvas,
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: geometry.size.height * 0.3)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .background(AppColor.Surface.canvas)
            .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.xxxl) {
                BreedForm(jenisSapi: $cattleBreed)
                
                GenderForm(genderSapi: $cattleGender)
            }
        }
    }
}

#Preview {
    @Previewable @State var cattleBreed: CattleBreed?
    @Previewable @State var cattleGender: CattleGender?
    
    SecondPageForm(cattleBreed: $cattleBreed, cattleGender: $cattleGender)
}
