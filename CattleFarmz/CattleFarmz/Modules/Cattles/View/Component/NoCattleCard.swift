//
//  NoCattleCard.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 05/11/26.
//

import SwiftUI

struct NoCattleCard: View {
    let copy: String
    var body: some View {
        VStack {
            Image(.cattle)
                .padding(.vertical, AppSpacing.lg)
            
            VStack (spacing: AppSpacing.sm){
                Text(copy)
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
        .shadow(
            color: Color(red: 0.000, green: 0.000, blue: 0.000, opacity: 0.05),
            radius: 5,
            x: 0,
            y: 4
        )
    }
}

#Preview {
    NoCattleCard(copy: "Belum ada sapi")
}
