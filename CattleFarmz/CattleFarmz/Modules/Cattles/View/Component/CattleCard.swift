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
                }
            }
            .padding(.bottom, AppSpacing.sm)
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Bobot")
                        .font(AppFont.body)
                    Text("Update: \(formatDate(updated))")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.Text.secondary)
                }
                Spacer()
                Text(
                    weight == nil
                    ? "Not measured"
                    : String(format: "%.2f kg", weight!)
                )
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.Text.secondary)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity)
        .background(AppColor.Card.background)
        .cornerRadius(16)
        .shadow(radius: 10, x: 0, y: 2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.timeZone = TimeZone(identifier: "Asia/Jakarta")
        formatter.dateFormat = "d MMMM yyyy, HH.mm 'WIB'"

        return formatter.string(from: date)
    }
}

#Preview {
    CattleCard(
        cattleImage: UIImage(named: "CattlePlaceholder")!, name: "Salman Boat", breed: .friesianHolstein, gender: .female, age: 12, weight: 69.69, updated: .now
    )
}
