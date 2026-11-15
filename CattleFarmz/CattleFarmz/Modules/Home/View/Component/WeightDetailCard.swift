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
    var chestGirth: Double?
    var bodyLength: Double?
    var dateAcquired: Date
    var action: () -> Void
    
    var formattedDateAcquired: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.timeZone = TimeZone(identifier: "Asia/Jakarta")
        formatter.dateFormat = "d MMMM yyyy, HH.mm"
        
        return "\(formatter.string(from: dateAcquired)) WIB"
    }
    
    var body: some View {
        VStack {
            Image(uiImage: cattleImage)
                .resizable()
                .scaledToFill()
                .frame(width: .infinity, height: 198)
                .clipped()
            
            VStack (spacing: AppSpacing.md){
                VStack (alignment: .leading, spacing: 8){
                    Text("Estimasi Bobot")
                        .font(AppFont.mediumBody)
                        .foregroundStyle(AppColor.Primitive.Neutral.shade950)
                    
                    Text("\(bodyWeight.formatted(.number.precision(.fractionLength(2)))) kg")
                        .font(AppFont.largeTitle)
                        .foregroundStyle(AppColor.Primitive.Secondary.shade900)
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColor.Primitive.Secondary.shade50)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [AppColor.Primitive.Secondary.shade500, AppColor.Primitive.Secondary.shade50]),
                                        startPoint: .topTrailing,
                                        endPoint: .bottomLeading
                                    ),
                                    lineWidth: 2
                                )
                )
                .cornerRadius(18)
                
                VStack (spacing: AppSpacing.xs){
                    HStack(spacing: AppSpacing.xs) {
                        VStack(spacing: AppSpacing.xxs){
                            Text("Lingkar Dada")
                                .font(AppFont.caption)
                            Text(chestGirth.map { "\($0.formatted(.number.precision(.fractionLength(1)))) cm" } ?? "Belum tersedia")
                                .font(AppFont.mediumBody)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        Divider()
                            .frame(height: 45)
                        
                        VStack(spacing: AppSpacing.xxs){
                            Text("Panjang Badan")
                                .font(AppFont.caption)
                            Text(bodyLength.map { "\($0.formatted(.number.precision(.fractionLength(1)))) cm" } ?? "Belum tersedia")
                                .font(AppFont.mediumBody)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    Text("Pengambilan data: \(formattedDateAcquired)")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.Primitive.Neutral.shade400)
                        .padding(.vertical, AppSpacing.sm)
                    
                    Button {
                        action()
                    } label: {
                        Text("Ambil Ulang")
                            .font(AppFont.body)
                            .foregroundStyle(AppColor.Primitive.Primary.shade500)
                            .padding(.vertical, AppSpacing.md)
                            .frame(maxWidth: .infinity)
                            .glassEffect(
                                .regular
                                    .tint(AppColor.Primitive.Primary.shade100)
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
            dateAcquired: Date(),
            action: {}
        )
    }
}
