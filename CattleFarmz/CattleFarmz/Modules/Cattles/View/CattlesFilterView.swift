//
//  CattlesFilterView.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 05/11/26.
//

import SwiftUI

struct CattlesFilterView: View {
    @Environment(\.dismiss) var cancel
    
    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()
            
            VStack (alignment: .leading) {
                Text("Jenis Sapi")
            }
        }
        .navigationTitle("Filter")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    cancel()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        })
    }
}

#Preview {
    NavigationStack {
        CattlesFilterView()
    }
}
