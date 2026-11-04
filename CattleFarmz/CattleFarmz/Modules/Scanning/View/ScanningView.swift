//
//  ScanningView.swift
//  CattleFarmz
//

import SwiftUI

/// Placeholder for the LiDAR scanning flow.
struct ScanningView: View {
    @State private var isCameraOpen = false
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background
                    .ignoresSafeArea()
                
                VStack {
                    Text("Scan placeholder")
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.textSecondary)
                    
                    Button {
                        isCameraOpen = true
                    } label: {Label("Buka kamera LiDAR",systemImage:"camera.fill")
                            .frame(maxWidth:.infinity)
                            .padding(.vertical, 10)
                    }.buttonStyle(.borderedProminent)
                    
                }
            }
        }
        .fullScreenCover(isPresented: $isCameraOpen){
            CameraView()
        }
    }
}

#Preview {
    ScanningView()
}
