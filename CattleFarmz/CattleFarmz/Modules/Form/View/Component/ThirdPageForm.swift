//
//  ThirdPageForm.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 19/11/26.
//

import SwiftUI

struct ThirdPageForm: View {
    @Binding var bobotCattle: Double?
    @Binding var cattlePhoto: UIImage?
    @Binding var scanResult: ScanResult?
    @Binding var jenisSapi: CattleBreed?
    @Binding var genderSapi: CattleGender?
    let isActive: Bool
    var offersScanPhoto: Bool = true
    let onScanSession: (@escaping (ScanResult?) -> Void) -> Void

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                LinearGradient(
                    colors: [
                        AppColor.Primitive.Secondary.shade100,
                        AppColor.Surface.canvas,
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: geometry.size.height * 0.3)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .background(AppColor.Surface.canvas)
            .ignoresSafeArea()

            VStack {
                CattlesWeightForm(
                    bobotCattle: $bobotCattle,
                    cattlePhoto: $cattlePhoto,
                    scanResult: $scanResult,
                    jenisSapi: $jenisSapi,
                    genderSapi: $genderSapi,
                    isActive: isActive,
                    offersScanPhoto: offersScanPhoto,
                    onScanSession: onScanSession
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var bobotCattle: Double?
    @Previewable @State var cattlePhoto: UIImage?
    @Previewable @State var scanResult: ScanResult?
    @Previewable @State var jenisSapi: CattleBreed?
    @Previewable @State var genderSapi: CattleGender?
    
    ThirdPageForm(
        bobotCattle: $bobotCattle,
        cattlePhoto: $cattlePhoto,
        scanResult: $scanResult,
        jenisSapi: $jenisSapi,
        genderSapi: $genderSapi,
        isActive: true,
        onScanSession: {_ in }
    )
}
