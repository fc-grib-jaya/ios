//
//  PrimaryButton.swift
//  CattleFarmz
//
//  Created by Salman on 08/11/26.
//

import SwiftUI

enum AppButtonVariants {
    case primary
    case secondary
    case text
}

struct AppButtonStyle: ButtonStyle {
    var variant: AppButtonVariants
    
    @Environment(\.isEnabled) private var isEnabled
    
    var foregroundColor: Color {
        switch variant {
        case .primary:
            return AppColor.Text.primary
        case .secondary:
            return AppColor.Text.secondary
        case .text:
            return AppColor.Text.secondary
        }
    }
    
    var backgroundColor: Color {
        if !isEnabled {
            return AppColor.Primitive.Primary.shade200
        }
        
        switch variant {
        case .primary:
            return AppColor.Button.Primary.background
        case .secondary:
            return AppColor.Button.Secondary.background
        case .text:
            return .clear
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.body)
            .foregroundStyle(foregroundColor)
            .padding(.vertical, AppSpacing.md)
            .frame(maxWidth: .infinity)
            .glassEffect(
                .regular
                    .tint(backgroundColor)
            )
    }
}

extension View {
    func AppButtonStyle(_ variant: AppButtonVariants) -> some View {
        self.buttonStyle(CattleFarmz.AppButtonStyle(variant: variant))
    }
}
#Preview {
    Button {
        
    } label: {
        Text("cihuy")
    }
    .AppButtonStyle(.primary)
    .disabled(true)
    
    Button {
        
    } label: {
        Text("cihuy")
    }
    .buttonStyle(AppButtonStyle(variant: .primary))
    
    Button {
        
    } label: {
        Text("cihuy")
    }
    .AppButtonStyle(.secondary)
    
    Button {
        
    } label: {
        Text("cihuy")
    }
    .buttonStyle(AppButtonStyle(variant: .text))
}
