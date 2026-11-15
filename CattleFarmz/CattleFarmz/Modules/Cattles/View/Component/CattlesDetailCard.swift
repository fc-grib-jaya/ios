//
//  CattlesDetailCard.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 07/11/26.
//

import SwiftUI

struct CattlesDetailCard: View {
    let name: String
    let breed: CattleBreed
    let gender: CattleGender
    let age: Int
    let weight: Double?
    let updatedDate: Date
    let chestGirth: Double?
    let bodyLength: Double?
    let notes: String?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(name)
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.Text.primary)

                Text("\(breed.rawValue) • \(gender.rawValue) • \(age) bulan")
                    .font(AppFont.body)
            }
            .padding(.bottom, AppSpacing.xs)

            VStack(spacing: AppSpacing.xs) {
                WeightDetailCardDylan(weight: weight, updated: updatedDate)
                    .padding(.bottom, AppSpacing.sm)
                

                HStack(spacing: AppSpacing.xs) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Lingkar Dada")
                            .font(AppFont.body)
                            .foregroundStyle(AppColor.Text.primary)

                        Text(
                            chestGirth == nil
                            ? "Belum diukur"
                            : String(format: "%.2f cm", chestGirth!)
                        )
                            .font(AppFont.mediumBody)
                            .foregroundStyle(AppColor.Text.primary)
                    }
                    
                    Spacer()
                    Divider()
                        .frame(width: AppSpacing.xxxs, height: AppSpacing.huge)
                        .overlay(AppColor.Primitive.Neutral.shade200)
                    
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Panjang Badan")
                            .font(AppFont.body)
                            .foregroundStyle(AppColor.Text.primary)

                        Text(
                            bodyLength == nil
                            ? "Belum diukur"
                            : String(format: "%.2f cm", bodyLength!)
                        )
                            .font(AppFont.mediumBody)
                            .foregroundStyle(AppColor.Text.primary)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, AppSpacing.xs)
                
                Divider()
                    .frame(height: AppSpacing.xxxs)
                    .overlay(AppColor.Primitive.Neutral.shade200)
                    .padding(.bottom, AppSpacing.xs)
                
                VStack(alignment: .leading) {
                    Text("Catatan")
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.Primitive.Neutral.shade400)
                    
                    Text(
                        notes == nil
                        ? "Tidak ada catatan"
                        : notes!
                    )
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.Primitive.Neutral.shade400)
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 23)
                                .fill(AppColor.Input.background)
                        )
                }
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
    CattlesDetailCard(
        name: "Dylan",
        breed: .friesianHolstein,
        gender: .male,
        age: 22,
        weight: 69.69,
        updatedDate: .now,
        chestGirth: 120,
        bodyLength: 250,
        notes: nil
    )
}
