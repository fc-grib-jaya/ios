//
//  NoCattleCard.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 05/11/26.
//

import SwiftUI

struct NoCattleCard: View {
    var body: some View {
        VStack {
            Image(.cattle)
                .padding(.vertical, AppSpacing.lg)
            
            VStack (spacing: AppSpacing.sm){
                Text("Belum ada sapi")
                    .font(AppFont.headline)
                Text("Isi data untuk menambahkan sapi")
                    .font(AppFont.body)
            }
            .padding(.bottom, AppSpacing.md)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity)
        .background(AppColor.Primitive.Base.white)
        .cornerRadius(16)
        .shadow(radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NoCattleCard()
}
