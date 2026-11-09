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
        }
        .AppButtonStyle(.primary)
        .padding(.horizontal, AppSpacing.md)
    }
}

#Preview {
    AddCattleButton(tambahSapi: .constant(false))
}
