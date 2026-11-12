//
//  NoRationCard.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 10/11/26.
//

import SwiftUI

struct NoRationCard: View {
    let onAddTap: () -> Void
    
    var body: some View {
        VStack {
            Image(.grass)
                .padding(.vertical, AppSpacing.lg)
            
            VStack (spacing: AppSpacing.sm){
                Text("Belum Menghitung Pakan")
                    .font(AppFont.headline)
                Text("Isi data pakan untuk menampilkan data")
                    .font(AppFont.body)
                
                Button(action: onAddTap) {
                    Text("Hitung Pakan")
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.Button.Primary.foreground)
                        .padding(.vertical, AppSpacing.xs)
                        .frame(maxWidth: .infinity)
                        .glassEffect(.regular.tint(AppColor.Primitive.Primary.shade500))
                }
                .padding(.horizontal, AppSpacing.md)
            }
            .padding(.bottom, AppSpacing.md)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity)
        .background(AppColor.Surface.canvas)
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
    NoRationCard(onAddTap: {})
}
