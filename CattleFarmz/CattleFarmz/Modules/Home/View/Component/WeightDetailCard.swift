//
//  WeightDetailCard.swift
//  CattleFarmz
//
//  Created by Salman on 09/11/26.
//

import SwiftUI

struct WeightDetailCard: View {
    var cattleImage: UIImage
    var bodyWeight: Double
    var chestGirth: Double
    var bodyLength: Double
    var dateAcquired: Date
    
    var formattedDateAcquired: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.timeZone = TimeZone(identifier: "Asia/Jakarta")
        formatter.dateFormat = "d MMMM yyyy, HH.mm"
        
        // Menggabungkan hasil format dengan teks "WIB"
        return "\(formatter.string(from: dateAcquired)) WIB"
    }
    
    var body: some View {
        VStack {
            Image(uiImage: cattleImage)
                .resizable()
                .scaledToFill()
                .frame(width: .infinity, height: 198, alignment: .topLeading)
                .clipped()
            
            VStack (spacing: AppSpacing.md){
                VStack (alignment: .leading, spacing: 8){
                    Text("Estimasi Bobot")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.Text.primary)
                    
                    Text("\(bodyWeight.formatted(.number.precision(.fractionLength(1)))) kg")
                        .font(AppFont.largeTitle)
                        .foregroundStyle(AppColor.Text.primary)
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColor.Primitive.Secondary.shade600)
                .cornerRadius(18)
                
                VStack (spacing: AppSpacing.xs){
                    HStack(spacing: AppSpacing.xs) {
                        VStack(spacing: AppSpacing.xxs){
                            Text("Lingkar Dada")
                                .font(AppFont.caption)
                            Text("\(chestGirth.formatted(.number.precision(.fractionLength(1)))) cm")
                                .font(AppFont.mediumBody)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        Divider()
                            .frame(height: 45)
                        
                        VStack(spacing: AppSpacing.xxs){
                            Text("Panjang Badan")
                                .font(AppFont.caption)
                            Text("\(bodyLength.formatted(.number.precision(.fractionLength(1)))) cm")
                                .font(AppFont.mediumBody)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    Text("Pengambilan data: \(formattedDateAcquired)")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.Primitive.Neutral.shade400)
                    
                    Button {
                        
                    } label: {
                        Text("Ambil Ulang")
                            .font(AppFont.body)
                            .foregroundStyle(AppColor.Primitive.Primary.shade500)
                            .padding(.vertical, AppSpacing.md)
                            .frame(maxWidth: .infinity)
                            .glassEffect(
                                .regular
                                    .tint(AppColor.Button.Secondary.background)
                            )
                    }
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)

            }
            .padding(.vertical, AppSpacing.md)
            .padding(.horizontal, AppSpacing.xs)
        }
        .background(AppColor.Card.background)
        .cornerRadius(14)
    }
}

#Preview {
    ZStack{
        AppColor.Primitive.Neutral.shade400
            .ignoresSafeArea()
        
        WeightDetailCard(
            cattleImage: UIImage(named: "CattlePlaceholder")!,
            bodyWeight: 573.4,
            chestGirth: 174,
            bodyLength: 200,
            dateAcquired: Date()
        )
    }
}
