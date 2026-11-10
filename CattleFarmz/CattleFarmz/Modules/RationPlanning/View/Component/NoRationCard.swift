//
//  NoRationCard.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 10/11/26.
//

import SwiftUI

struct NoRationCard: View {
//    let onAddTap: () -> Void
    
    var body: some View {
        VStack {
            Image(.grass)
                .padding(.vertical, AppSpacing.lg)
            
            VStack (spacing: AppSpacing.sm){
                Text("Belum Menghitung Pakan")
                    .font(AppFont.headline)
                Text("Isi data pakan untuk menampilkan data")
                    .font(AppFont.body)
                
                // Harus disesuain sama button salman
                Button {
//                    onAddTap()
                } label: {
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
        .shadow(radius: 5, x: 0, y: 2)
    }
}

#Preview {
//    NoRationCard(onAddTap: {})
    NoRationCard()
}
