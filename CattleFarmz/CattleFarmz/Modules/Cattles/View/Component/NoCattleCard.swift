//
//  NoCattleCard.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 05/11/26.
//

import SwiftUI

// f/23 ya
struct NoCattleCard: View {
    @Binding var tambahSapi: Bool
    
    var body: some View {
        VStack {
            Image(.cattle)
                .padding(.bottom, AppSpacing.lg)
            
            VStack (spacing: AppSpacing.sm){
                Text("Belum ada sapi")
                    .font(AppFont.headline)
                Text("Isi data untuk menambahkan sapi")
                    .font(AppFont.body)
            }
            .padding(.bottom, AppSpacing.md)
            
            AddCattleButton(tambahSapi: $tambahSapi)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity)
        .background(AppColor.Primitive.Primary.shade500)
        .cornerRadius(16)
        .shadow(radius: 10, x: 0, y: 2)
    }
}

#Preview {
    NoCattleCard(tambahSapi: .constant(false))
}
