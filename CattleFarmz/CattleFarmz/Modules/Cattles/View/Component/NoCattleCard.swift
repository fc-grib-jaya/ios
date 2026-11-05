//
//  NoCattleCard.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 05/11/26.
//

import SwiftUI

struct NoCattleCard: View {
    @Binding var tambahSapi: Bool
    
    var body: some View {
        VStack {
            Image(.cattle)
                .padding(.bottom, AppSpacing.large)
            
            VStack (spacing: AppSpacing.small){
                Text("Belum ada sapi")
                    .font(AppFont.headline)
                Text("Isi data untuk menambahkan sapi")
                    .font(AppFont.body)
            }
            .padding(.bottom, AppSpacing.medium)
            
            AddCattleButton(tambahSapi: $tambahSapi)
        }
        .padding(AppSpacing.medium)
        .frame(maxWidth: .infinity)
        .background(AppColor.background)
        .cornerRadius(16)
        .shadow(radius: 10, x: 0, y: 2)
    }
}

#Preview {
    NoCattleCard(tambahSapi: .constant(false))
}
