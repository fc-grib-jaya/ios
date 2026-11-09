//
//  CattleCard.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 05/11/26.
//

import SwiftUI

struct CattleCard: View {
    let cattleImage: UIImage
    let name: String
    let breed: CattleBreed
    let gender: CattleGender
    let age: Int
    let weight: Double?
    let updated: Date
    
    var body: some View {
        VStack (alignment: .leading){
            HStack {
                Image(uiImage: cattleImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.trailing, AppSpacing.sm)
                
                VStack(alignment: .leading) {
                    Text(name)
                        .font(AppFont.title)
                    Text("\(breed.rawValue) • \(gender.rawValue) • \(age) bulan")
                        .font(AppFont.body)
                }
            }
            .padding(.bottom, AppSpacing.sm)
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Bobot")
                        .font(AppFont.body)
                    Text("Diperbaharui: \(formatDate(updated))")
                        .font(AppFont.caption)
                        .fontWeight(.thin)
                        .foregroundStyle(AppColor.Text.secondary)
                }
                Spacer()
                Text(
                    weight == nil
                    ? "Belum diukur"
                    : String(format: "%.2f kg", weight!)
                )
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.Primitive.Secondary.shade700)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity)
        .background(AppColor.Card.background)
        .cornerRadius(AppSpacing.Card.compact)
        .shadow(
            color: Color(red: 0.000, green: 0.000, blue: 0.000, opacity: 0.05),
            radius: 5,
            x: 0,
            y: 4
        )
        
    }
}

#Preview {
    CattleCard(
        cattleImage: UIImage(named: "CattlePlaceholder")!, name: "Salman Boat", breed: .friesianHolstein, gender: .female, age: 12, weight: 69.69, updated: .now
    )
}
