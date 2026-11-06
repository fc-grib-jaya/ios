//
//  AddCattleButton.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 05/11/26.
//

import SwiftUI

struct AddCattleButton: View {
    @Binding var tambahSapi: Bool
    
    var body: some View {
        Button {
            tambahSapi = true
        } label: {
            Text("+ Tambah Sapi")
                .font(AppFont.body)
                .foregroundStyle(AppColor.onPrimary)
                .padding(.vertical, AppSpacing.xm)
                .frame(maxWidth: .infinity)
                .glassEffect(.regular.tint(AppColor.primary))
        }
        .padding(.horizontal, AppSpacing.medium)
    }
}

#Preview {
    AddCattleButton(tambahSapi: .constant(false))
}
