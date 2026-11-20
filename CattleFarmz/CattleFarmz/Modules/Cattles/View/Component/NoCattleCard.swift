//
//  NoCattleCard.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 05/11/26.
//

import SwiftUI

struct NoCattleCard: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack {
            Image(.cattle)
                .padding(.vertical, AppSpacing.lg)
                .accessibilityLabel("Sapi")
            
            VStack (spacing: AppSpacing.sm){
                Text(title)
                    .font(AppFont.headline)
                Text(subtitle)
                    .font(AppFont.body)
            }
            .multilineTextAlignment(.center)
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
    NoCattleCard(title: "Belum ada sapi", subtitle: "Tambahkan sapi untuk mencatat bobot dan rencana pakannya.")
}
