//
//  CattlesPictureCard.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 16/11/26.
//

import SwiftUI

struct CattlesPictureCard: View {
    let cattleImage: Image
    let action: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 22)

        VStack(spacing: 0) {
            cattleImage
                .resizable()
                .scaledToFill()
                .frame(height: 198)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(alignment: .topLeading) {
                    Button(action: onRemove) {
                        Text("\(Image(systemName: "xmark"))")
                            .font(AppFont.caption)
                            .padding(AppSpacing.xxs)
                            .background(.regularMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Hapus foto profil sapi")
                    .padding(AppSpacing.sm)
                }

            Button(action: action) {
                Text("Ambil ulang")
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.Primitive.Secondary.shade600)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .background(AppColor.Primitive.Base.white, in: shape)
        .clipShape(shape)
        .overlay {
            shape.strokeBorder(
                AppColor.Primitive.Secondary.shade100,
                lineWidth: 1
            )
            .allowsHitTesting(false)
        }
    }
}

#Preview {
    CattlesPictureCard(cattleImage: Image("tesimage"), action: {}, onRemove: {})
}
