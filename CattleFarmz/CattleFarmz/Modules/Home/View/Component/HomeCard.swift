//
//  HomeCard.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 10/11/26.
//

import SwiftUI

struct HomeCard: View {
    let Farmer: String
    let Subtitle: Text
    private let onAddCattleTap: () -> Void

    init(Farmer: String, Subtitle: Text, onAddCattleTap: @escaping () -> Void) {
        self.Farmer = Farmer
        self.Subtitle = Subtitle
        self.onAddCattleTap = onAddCattleTap
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            HStack(alignment: .bottom) {
                Text(
                    """
                    Selamat 
                    \(Calendar.current.component(.hour, from: Date()) < 11
                        ? "Pagi"
                        : Calendar.current.component(.hour, from: Date()) < 15
                            ? "Siang"
                            : Calendar.current.component(.hour, from: Date()) < 19
                                ? "Sore"
                                : "Malam") \(Farmer)!
                    """
                )
                .font(AppFont.title)
                .foregroundStyle(AppColor.Primitive.Secondary.shade900)
                
                Spacer()
                
                Subtitle
                    .font(AppFont.body)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.top, AppSpacing.md)
            .padding(.horizontal, AppSpacing.md)
            
//            AppButtons("+ Tambah Sapi", variant: .primary, action: onAddCattleTap)
            
            AddCattleButton(onTap: onAddCattleTap)
                .padding(.vertical, AppSpacing.md)
        }
        .background(AppColor.Card.background)
        .cornerRadius(AppSpacing.Card.compact)
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.md)
    }
}

#Preview {
    HomeCard(Farmer: "Joni", Subtitle: Text("Apa aja"), onAddCattleTap: {})
}
