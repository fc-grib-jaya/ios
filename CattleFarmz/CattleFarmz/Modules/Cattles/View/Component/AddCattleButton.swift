//
//  AddCattleButton.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 05/11/26.
//

import SwiftUI

struct AddCattleButton: View {
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            Text("+ Tambah Sapi")
        }
        .appButtonStyle(.primary)
        .padding(.horizontal, AppSpacing.md)
    }
}

#Preview {
    AddCattleButton(onTap: {})
}
