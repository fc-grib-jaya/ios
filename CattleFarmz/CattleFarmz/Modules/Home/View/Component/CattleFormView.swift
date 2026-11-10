//
//  CattleFormView.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 04/11/26.
//

import SwiftUI
import UIKit

struct CattleFormView: View {
    @State private var namaCattle = ""
    @State private var jenisCattle: CattleBreed?
    @State private var genderCattle: CattleGender?
    @State private var umurCattle: Int?
    @State private var bobotCattle: Double?
    @State private var gambarCattle: UIImage?
    @State private var catatan = ""
    
    @Environment(\.dismiss) var cancel
    /// Starts one scan session. `onFinish` receives the measurement, or `nil` when the user cancelled.
    let onScanSession: (@escaping (ScanResult?) -> Void) -> Void
    let viewModel: CattleFormViewModel
    let onSave: (
        String,
        Date,
        CattleBreed,
        CattleGender,
        Int,
        Double?,
        UIImage?,
        String?
    ) async throws -> Void
    @State private var saveError: String?
    
    private enum WeightEntryMode {
        case manual
        case camera
    }
    @State private var weightEntryMode: WeightEntryMode = .manual
    @State private var isShowingCamera = false
    
    var body: some View {
        ZStack {
            AppColor.Surface.canvas
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack (alignment: .leading, spacing: AppSpacing.md){
                    VStack (alignment: .leading){
                        HStack (spacing: 1){
                            Text("Nama Sapi")
                                .foregroundStyle(AppColor.Text.primary)
                            Text("*")
                                .foregroundStyle(Color.red)
                        }
                        .font(AppFont.body)
                        
                        TextField("Tuliskan Nama Sapi", text: $namaCattle)
                            .font(AppFont.body)
                            .autocorrectionDisabled()
                            .padding(AppSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: 23)
                                    .fill(AppColor.Input.background)
                            )
                    }
                    
                    VStack (alignment: .leading){
                        HStack(spacing: 1) {
                            Text("Jenis Sapi")
                                .foregroundStyle(AppColor.Text.primary)
                            Text("*")
                                .foregroundStyle(Color.red)
                        }
                        .font(AppFont.body)
                        
                        Picker("Masukkan Jenis Sapi", selection: $jenisCattle) {
                            Text("Masukkan Jenis Sapi")
                                .tag(nil as CattleBreed?)
                            
                            ForEach(CattleBreed.allCases) { breed in
                                Text(breed.rawValue)
                                    .tag(breed)
                            }
                        }
                        .pickerStyle(.menu)
                        .font(AppFont.body)
                        .tint(
                            jenisCattle == nil ? AppColor.Text
                                .secondary.opacity(0.5) : AppColor.Text.primary
                        )
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 23)
                                .fill(AppColor.Surface.canvas)
                        )
                    }
                    
                    VStack (alignment: .leading){
                        HStack (spacing: 1) {
                            Text("Jenis Kelamin Sapi")
                                .foregroundStyle(AppColor.Text.primary)
                            Text("*")
                                .foregroundStyle(Color.red)
                        }
                        .font(AppFont.body)
                        
                        HStack(spacing: AppSpacing.md) {
                            ForEach(CattleGender.allCases, id: \.self) { gender in
                                let isSelected = genderCattle == gender
                                
                                Button {
                                    genderCattle = gender
                                } label: {
                                    HStack(spacing: AppSpacing.sm) {
                                        Image(systemName: isSelected
                                              ? "largecircle.fill.circle"
                                              : "circle")
                                        Text(gender.rawValue)
                                        Spacer()
                                    }
                                    .font(AppFont.body)
                                    .foregroundStyle(
                                        isSelected ? AppColor.Button.Primary.background : AppColor.Button.Secondary.foreground
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(AppSpacing.xs)
                                    .background(
                                        RoundedRectangle(cornerRadius: 30)
                                            .fill(
                                                isSelected ? AppColor.Card.background
                                                    .opacity(
                                                        0.2
                                                    ) : AppColor.Surface.canvas
                                            )
                                            .stroke(
                                                isSelected ? AppColor.Border.focus : AppColor.Border.subtle
                                                    .opacity(0.2)
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    VStack (alignment: .leading){
                        HStack (spacing: 1) {
                            Text("Usia Sapi (Bulan)")
                                .foregroundStyle(AppColor.Text.primary)
                            Text("*")
                                .foregroundStyle(Color.red)
                        }
                        .font(AppFont.body)
                        
                        TextField(
                            value: $umurCattle,
                            format: .number,
                            prompt: Text("e.g. \"12\"").italic()
                        ) {
                            Text("Usia Sapi (Bulan)")
                        }
                        .keyboardType(.numberPad)
                        .font(AppFont.body)
                        .onChange(of: umurCattle) { _, value in
                            guard let value else { return }
                            
                            if value > 99 {
                                umurCattle = 99
                            } else if value < 0 {
                                umurCattle = 0
                            }
                        }
                        .padding(AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 23)
                                .fill(AppColor.Surface.canvas)
                        )
                    }
                    
                    Text("Bobot dan Foto Sapi")
                        .foregroundStyle(AppColor.Text.primary)
                        .font(AppFont.body)
                    VStack (alignment: .leading){
                        
                        VStack (alignment: .leading){
                            Picker("weight Entry Mode", selection: $weightEntryMode){
                                Text("Isi Bobot").tag(WeightEntryMode.manual)
                                Text("Estimasi Bobot").tag(WeightEntryMode.camera)
                            }
                            .pickerStyle(.segmented)
                            
                            if (weightEntryMode == .manual) {
                                Text("Masukkan bobot secara manual, lalu ambil foto untuk profil sapi.")
                                    .font(AppFont.caption)
                                    .padding(.bottom, AppSpacing.sm)
                                
                                HStack (spacing: 1) {
                                    Text("Bobot")
                                        .foregroundStyle(AppColor.Text.primary)
                                    Text("*")
                                        .foregroundStyle(Color.red)
                                }
                                .font(AppFont.body)
                                
                                HStack {
                                    TextField(
                                        value: $bobotCattle,
                                        format: .number,
                                        prompt: Text("e.g. \"604,19\"").italic()
                                    ) {
                                        Text("Bobot Sapi (kg)")
                                    }
                                    .keyboardType(.decimalPad)
                                    
                                    Text("kg")
                                        .foregroundStyle(AppColor.Text.primary)
                                }
                                .padding(AppSpacing.xs)
                                .background(
                                    RoundedRectangle(cornerRadius: 23)
                                        .fill(AppColor.Surface.canvas)
                                )
                                
                                //Capture session
                                Button {
                                    isShowingCamera = true
                                } label: {
                                    VStack(spacing: AppSpacing.md) {
                                        if let gambarCattle {
                                            Image(uiImage: gambarCattle)
                                                .resizable()
                                                .scaledToFill()
                                                .aspectRatio(1, contentMode: .fit)
                                                .frame(maxWidth: .infinity)
                                                .clipShape(RoundedRectangle(cornerRadius: 23))
                                        } else {
                                            VStack {
                                                Image(systemName: "camera.fill")
                                                    .font(AppFont.largeTitle)
                                                Text("Ambil foto sapi")
                                                    .italic()
                                            }
                                            .padding(.vertical, AppSpacing.xl)
                                        }
                                    }
                                    .font(AppFont.body)
                                    .foregroundStyle(AppColor.Text.secondary.opacity(0.5))
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 23)
                                            .fill(AppColor.Surface.canvas)
                                            .stroke(AppColor.Text.secondary, style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
                                    )
                                }
                                .buttonStyle(.plain)
                            } else {
                                Text("Estimasi bobot dengan kamera. Foto yang sama digunakan sebagai foto profil sapi.")
                                    .font(AppFont.caption)
                                    .padding(.bottom, AppSpacing.sm)
                                
                                HStack {
                                    Text("\(Image(systemName: "exclamationmark.circle")) Pilih jenis sapi untuk mulai estimasi.")
                                        .font(AppFont.caption)
                                    Spacer()
                                }
                                .padding(AppSpacing.xs)
                                .background(
                                    RoundedRectangle(cornerRadius: 23)
                                        .fill(AppColor.Surface.canvas)
                                )
                                
                                if (viewModel.scanResult == nil){
                                    Button {
                                        // Lidar
                                        onScanSession { result in
                                            viewModel.storeScanResult(result)
                                            syncEstimatedWeight()
                                            print(result)
                                        }
                                    } label: {
                                        VStack {
                                            Image(systemName: "camera.on.rectangle.fill")
                                                .font(AppFont.largeTitle)
                                            Text("Estimasi bobot dan foto sapi")
                                                .italic()
                                                .lineLimit(1)
                                        }
                                        .font(AppFont.body)
                                        .foregroundStyle(AppColor.Text.secondary.opacity(0.5))
                                        .padding(.vertical, AppSpacing.xl)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 23)
                                                .fill(AppColor.Surface.canvas)
                                                .stroke(
                                                    AppColor.Text.secondary,
                                                    style: StrokeStyle(
                                                        lineWidth: 1,
                                                        dash: [2, 3]
                                                    )
                                                )
                                        )
                                    }
                                    .buttonStyle(.plain)
                                } else if let scan = viewModel.scanResult {
                                    if let girth = scan.girth,
                                       let weight = bobotCattle {
                                        WeightDetailCard(
                                            cattleImage: scan.cattleImage,
                                            bodyWeight: weight,
                                            chestGirth: girth,
                                            bodyLength: scan.lengthCM,
                                            dateAcquired: Date()
                                        ) {
                                            onScanSession { result in
                                                viewModel.storeScanResult(result)
                                                syncEstimatedWeight()
                                                print(result)
                                            }
                                        }
                                    } else {
                                        Text("Panjang badan: \(scan.lengthCM.formatted()) cm")
                                        Text("Lingkar dada: \(scan.girth) cm")
                                    }
                                }
                            }
                        }
                    }
                    .font(AppFont.body)
                    .padding(AppSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: 23)
                            .fill(AppColor.Surface.canvas.opacity(0.5))
                    )
                    
                    VStack (alignment: .leading){
                        Text("Catatan")
                            .font(AppFont.body)
                            .foregroundStyle(AppColor.Text.primary)
                        
                        TextField(
                            text: $catatan,
                            prompt: Text("e.g., \"Letak kandang ada di pojok.\"").italic()
                        ) {
                            Text("Catatan")
                        }
                        .font(AppFont.body)
                        .autocorrectionDisabled()
                        .padding(AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 23)
                                .fill(AppColor.Surface.canvas)
                        )
                    }
                    .padding(.bottom, AppSpacing.lg)
                    
                    Button {
                        guard let breed = jenisCattle,
                              let gender = genderCattle else {
                            return
                        }
                        
                        guard let umurCattle else { return }
                        
                        Task {
                            do {
                                try await onSave(namaCattle, .now, breed, gender, umurCattle, bobotCattle, gambarCattle, catatan)
                                cancel()
                            } catch {
                                saveError = error.localizedDescription
                            }
                        }
                    } label: {
                        Text("Simpan Data")
                    }
                    .AppButtonStyle(.primary)
                    .disabled(isSaveDisabled)
                }
                .padding()
            }
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            CameraPicker(
                image: $gambarCattle,
                isPresented: $isShowingCamera
            )
            .ignoresSafeArea()
        }
        .navigationTitle("Tambah Sapi")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: jenisCattle) { _, _ in
            syncEstimatedWeight()
        }
        .onChange(of: genderCattle) { _, _ in
            syncEstimatedWeight()
        }
    }
    
    
    /// Fills `bobotCattle` from the stored scan once breed and gender are both
    /// selected; recalculated whenever either field changes.
    private func syncEstimatedWeight() {
        bobotCattle = viewModel.estimatedWeight(breed: jenisCattle, gender: genderCattle)
    }
    
    private var isSaveDisabled: Bool {
        namaCattle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || jenisCattle == nil
        || genderCattle == nil
        || umurCattle == nil
        || (weightEntryMode == .manual && bobotCattle == nil)
    }
}

#Preview {
    NavigationStack {
        CattleFormView(
            onScanSession: { _ in },
            viewModel: CattleFormViewModel(calculation: WeightCalculator())
        ) { _, _, _, _, _, _, _, _ in }
    }
}
