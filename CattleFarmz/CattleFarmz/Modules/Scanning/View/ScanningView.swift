//
//  ScanningView.swift
//  CattleFarmz
//

import SwiftUI

/// Placeholder for the LiDAR scanning flow.
struct ScanningView: View {
    var body: some View {
        ZStack {
            AppColor.Surface.canvas
                .ignoresSafeArea()

            Text("Scan placeholder")
                .font(AppFont.body)
                .foregroundStyle(AppColor.Text.secondary)
        }
    }
}

#Preview {
    ScanningView()
}
