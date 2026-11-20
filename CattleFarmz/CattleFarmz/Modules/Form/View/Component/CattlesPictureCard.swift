//
//  CattlesPictureCard.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 16/11/26.
//

import SwiftUI

struct CattlesPictureCard: View {
    let cattleImage: Image?
    let action: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        VStack {
            Button(action: action) {
                if let cattleProfile = cattleImage {
                    cattleProfile
                        .resizable()
                        .scaledToFill()
                        .frame(width: 85, height: 85)
                        .clipped()
                        .cornerRadius(AppSpacing.lg)
                } else {
                    Image(.cattleShape)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                        .frame(width: 85, height: 85)
                        .background(AppColor.Surface.canvas)
                        .cornerRadius(AppSpacing.lg)
                }
            }
            .overlay {
                if cattleImage != nil {
                    RoundedRectangle(cornerRadius: AppSpacing.lg)
                        .strokeBorder(
                            AppColor.Primitive.Neutral.shade600,
                        )
                        .allowsHitTesting(false)
                } else {
                    RoundedRectangle(cornerRadius: AppSpacing.lg)
                        .strokeBorder(
                            AppColor.Primitive.Neutral.shade400,
                            style: StrokeStyle(
                                lineWidth: 1,
                                dash: [5, 3]
                            )
                        )
                        .allowsHitTesting(false)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if(cattleImage == nil) {
                    Button(action: action) {
                        Text("\(Image(systemName: "plus"))")
                            .font(AppFont.body).bold()
                            .foregroundStyle(AppColor.Primitive.Base.white)
                            .padding(AppSpacing.xxs)
                            .background(AppColor.Primitive.Neutral.shade600, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Hapus foto profil sapi")
                    .offset(x: 5, y: 5)
                } else {
                    Button(action: onRemove) {
                        Text("\(Image(systemName: "xmark"))")
                            .font(AppFont.caption).bold()
                            .foregroundStyle(AppColor.Primitive.Base.white)
                            .padding(AppSpacing.xs)
                            .background(AppColor.Primitive.Neutral.shade600, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Hapus foto profil sapi")
                    .offset(x: 5, y: 5)
                }
                
            }
        }
    }
}

#Preview {
    CattlesPictureCard(cattleImage: Image(.tesimage), action: {}, onRemove: {})
}
