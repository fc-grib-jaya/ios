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
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.sm) {
                Image(.mainCattle)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70)
                
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(
                    """
                    \(Calendar.current.component(.hour, from: Date()) < 11
                        ? "Pagi"
                        : Calendar.current.component(.hour, from: Date()) < 15
                            ? "Siang"
                            : Calendar.current.component(.hour, from: Date()) < 19
                                ? "Sore"
                                : "Malam"), \(Farmer)!
                    """
                    )
                    .font(AppFont.formTitle)
                    .foregroundStyle(AppColor.Primitive.Primary.shade900)
                    
                    Subtitle
                        .font(AppFont.body)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.top, AppSpacing.md)
            .padding(.horizontal, AppSpacing.md)
            
            AddCattleButton(onTap: onAddCattleTap)
                .padding(.vertical, AppSpacing.md)
        }
        .background(
            LinearGradient(
                colors: [
                    AppColor.Primitive.Secondary.shade50,
                    AppColor.Primitive.Secondary.shade200,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(AppSpacing.Card.compact)
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.md)
    }
}

#Preview {
    HomeCard(Farmer: "Dylan", Subtitle: Text("Apa aja"), onAddCattleTap: {})
}
