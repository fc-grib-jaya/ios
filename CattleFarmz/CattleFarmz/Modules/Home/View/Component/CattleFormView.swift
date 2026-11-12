//
//  CattleFormView.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 04/11/26.
//

import SwiftUI
import UIKit

struct CattleFormValues {
    let name: String
    let dateAcquired: Date
    let breed: CattleBreed
    let gender: CattleGender
    let recordedAge: Int
    let bodyWeight: Double?
    let cattleImage: UIImage?
    let notes: String?
}

struct CattleFormView: View {
    let cattle: Cattle?
    @State private var namaCattle: String
    @State private var jenisCattle: CattleBreed?
    @State private var genderCattle: CattleGender?
    @State private var umurCattle: Int?
    @State private var bobotCattle: Double?
    @State private var gambarCattle: UIImage?
    @State private var displayedScanResult: ScanResult?
    @State private var catatan: String
    
    @Environment(\.dismiss) var cancel
    /// Starts one scan session. `onFinish` receives the measurement, or `nil` when the user cancelled.
    let onScanSession: (@escaping (ScanResult?) -> Void) -> Void
    let viewModel: CattleFormViewModel
    let onSave: (CattleFormValues) async throws -> Void
    @State private var saveError: String?
    
    private enum WeightEntryMode {
        case manual
        case camera
    }
    @State private var weightEntryMode: WeightEntryMode = .manual
    @State private var isShowingCamera = false
    
    init(
        cattle: Cattle? = nil,
        onScanSession: @escaping (@escaping (ScanResult?) -> Void) -> Void = { _ in },
        viewModel: CattleFormViewModel,
        onSave: @escaping (CattleFormValues) async throws -> Void
    ) {
        self.cattle = cattle
        self.onScanSession = onScanSession
        self.viewModel = viewModel
        self.onSave = onSave
        _namaCattle = State(initialValue: cattle?.name ?? "")
        _jenisCattle = State(initialValue: cattle?.breed)
        _genderCattle = State(initialValue: cattle?.gender)
        _umurCattle = State(initialValue: cattle?.recordedAge)
        _bobotCattle = State(initialValue: cattle?.bodyWeight)
        let existingImage = cattle?.cattleImage.flatMap(UIImage.init(data:))
        _gambarCattle = State(initialValue: existingImage)
        _catatan = State(initialValue: cattle?.notes ?? "")

        let existingScan = cattle.flatMap { cattle -> ScanResult? in
            guard let chestGirth = cattle.chestGirth,
                  let bodyLength = cattle.bodyLength else {
                return nil
            }

            return ScanResult(
                lengthCM: bodyLength,
                girth: chestGirth,
                cattleImage: existingImage
                    ?? UIImage(named: "CattlePlaceholder")
                    ?? UIImage()
            )
        }
        _displayedScanResult = State(initialValue: existingScan)
        _weightEntryMode = State(initialValue: cattle == nil ? .camera : .manual)
        if let existingScan {
            viewModel.storeScanResult(existingScan)
        }

    }
    
    var body: some View {
        ZStack {
            AppColor.Primitive.Base.white
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack (alignment: .leading, spacing: AppSpacing.md){
                    VStack (alignment: .leading){
                        HStack(spacing: 1) {
                            Text("Jenis Sapi")
                                .foregroundStyle(AppColor.Text.primary)
                            Text("*")
                                .foregroundStyle(Color.red)
                        }
                        .font(AppFont.body)
                        
                        Menu {
                            Picker("Jenis Sapi", selection: $jenisCattle) {
                                if jenisCattle == nil {
                                    Text("Masukkan Jenis Sapi")
                                        .tag(nil as CattleBreed?)
                                }

                                ForEach(CattleBreed.allCases) { breed in
                                    Text(breed.rawValue)
                                        .tag(breed as CattleBreed?)
                                }
                            }
                            .pickerStyle(.inline)
                        } label: {
                            HStack {
                                Text(jenisCattle?.rawValue ?? "Masukkan Jenis Sapi")
                                    .font(AppFont.body)

                                Spacer()

                                Image(systemName: "chevron.down")
                                    .font(.footnote)
                            }
                            .foregroundStyle(
                                jenisCattle == nil
                                    ? AppColor.Text.secondary.opacity(0.5)
                                    : AppColor.Text.primary
                            )
                            .padding(AppSpacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                AppColor.Primitive.Neutral.shade100,
                                in: RoundedRectangle(cornerRadius: 23)
                            )
                            .contentShape(Rectangle())
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 23)
                                .fill(AppColor.Primitive.Neutral.shade100)
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
                                AppRadioButton(
                                    LocalizedStringKey(gender.rawValue),
                                    value: gender,
                                    selection: $genderCattle
                                )
                            }
                        }
                    }
                    
                    
                    
                    Text("Bobot dan Foto Sapi")
                        .foregroundStyle(AppColor.Text.primary)
                        .font(AppFont.body)
                    VStack (alignment: .leading){
                        
                        VStack (alignment: .leading){
                            AppSegmentedControl(
                                "Cara mengisi bobot",
                                options: [WeightEntryMode.manual, .camera],
                                selection: $weightEntryMode
                            ) { mode in
                                Text(mode == .manual ? "Isi Bobot" : "Estimasi Bobot")
                            }
                            
                            if (weightEntryMode == .manual) {
                                Text("Masukkan bobot secara manual, lalu ambil foto untuk profil sapi.")
                                    .font(AppFont.caption)
                                    .padding(.vertical, AppSpacing.sm)
                                
                                HStack (spacing: 1) {
                                    Text(cattle == nil ? "Bobot" : "Bobot Sapi (Jika Ada)")
                                        .foregroundStyle(AppColor.Text.primary)
                                    if cattle == nil {
                                        Text("*")
                                            .foregroundStyle(Color.red)
                                    }
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
                                    
                                    Text("kg   ")
                                        .foregroundStyle(AppColor.Text.primary)
                                }
                                .padding(AppSpacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: 23)
                                        .fill(AppColor.Primitive.Neutral.shade100)
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
                                            .fill(AppColor.Primitive.Neutral.shade100)
                                            .stroke(AppColor.Text.secondary, style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
                                    )
                                }
                                .buttonStyle(.plain)
                            } else {
                                Text("Estimasi bobot dengan kamera. Foto yang sama digunakan sebagai foto profil sapi.")
                                    .font(AppFont.caption)
                                    .padding(.vertical, AppSpacing.sm)
                                
                                HStack {
                                    Text("\(Image(systemName: "exclamationmark.circle")) Pilih jenis sapi untuk mulai estimasi.")
                                        .font(AppFont.caption)
                                    Spacer()
                                }
                                .padding(AppSpacing.xs)
                                .background(
                                    RoundedRectangle(cornerRadius: 23)
                                        .fill(AppColor.Primitive.Neutral.shade100)
                                )
                                
                                if displayedScanResult == nil {
                                    Button {
                                        guard jenisCattle != nil, genderCattle != nil else {
                                            return
                                        }

                                        onScanSession { result in
                                            viewModel.storeScanResult(result)
                                            displayedScanResult = result
                                            gambarCattle = result.flatMap {
                                                viewModel.squareCroppedImage($0.cattleImage)
                                            }
                                            if let estimatedWeight = viewModel.estimatedWeight(breed: jenisCattle, gender: genderCattle) { bobotCattle = estimatedWeight }
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
                                                .fill(AppColor.Primitive.Neutral.shade100)
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
                                    .disabled(jenisCattle == nil || genderCattle == nil)
                                } else if let scan = displayedScanResult {
                                    if let girth = scan.girth,
                                       let weight = estimatedWeightForScan {
                                        WeightDetailCard(
                                            cattleImage: cattleImageForDisplay,
                                            bodyWeight: weight,
                                            chestGirth: girth,
                                            bodyLength: scan.lengthCM,
                                            dateAcquired: Date()
                                        ) {
                                            onScanSession { result in
                                                viewModel.storeScanResult(result)
                                                displayedScanResult = result
                                                gambarCattle = result.flatMap {
                                                    viewModel.squareCroppedImage($0.cattleImage)
                                                }
                                                if let estimatedWeight = viewModel.estimatedWeight(breed: jenisCattle, gender: genderCattle) { bobotCattle = estimatedWeight }
                                                print(result)
                                            }
                                        }
                                    } else {
                                        Text("Panjang badan: \(scan.lengthCM.formatted()) cm")
                                        Text("Lingkar dada: \(scan.girth) cm")
                                        
                                        Button {
                                            onScanSession { result in
                                                viewModel.storeScanResult(result)
                                                gambarCattle = result?.cattleImage
                                                syncEstimatedWeight()
                                                print(result)
                                            }
                                        } label: {
                                            Text("Ambil Ulang")
                                                .font(AppFont.body)
                                                .foregroundStyle(AppColor.Primitive.Primary.shade500)
                                                .padding(.vertical, AppSpacing.md)
                                                .frame(maxWidth: .infinity)
                                                .glassEffect(
                                                    .regular
                                                        .tint(AppColor.Button.Secondary.background)
                                                )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .font(AppFont.body)
                    .padding(AppSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: 23)
                            .fill(AppColor.Input.background.opacity(0.8))
                    )
                    
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
                                    .fill(AppColor.Primitive.Neutral.shade100)
                            )
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
                                .fill(AppColor.Primitive.Neutral.shade100)
                        )
                    }
                    
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
                                .fill(AppColor.Primitive.Neutral.shade100)
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
                                try await onSave(
                                    CattleFormValues(
                                        name: namaCattle,
                                        dateAcquired: cattle?.dateAcquired ?? .now,
                                        breed: breed,
                                        gender: gender,
                                        recordedAge: umurCattle,
                                        bodyWeight: bobotCattle,
                                        cattleImage: gambarCattle,
                                        notes: catatan.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : catatan
                                    )
                                )
                                cancel()
                            } catch {
                                saveError = error.localizedDescription
                            }
                        }
                    } label: {
                        Text(cattle == nil ? "Simpan Data" : "Simpan Perubahan")
                    }
                    .appButtonStyle(.primary)
                    .disabled(isSaveDisabled)
                }
                .padding(AppSpacing.md)
            }

        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            CameraPicker(
                image: $gambarCattle,
                isPresented: $isShowingCamera
            )
            .ignoresSafeArea()
        }
        .navigationTitle(cattle == nil ? "Tambah Sapi" : "Edit Sapi")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: jenisCattle) { _, _ in
            if let estimatedWeight = viewModel.estimatedWeight(breed: jenisCattle, gender: genderCattle) { bobotCattle = estimatedWeight }
        }
        .onChange(of: genderCattle) { _, _ in
            if let estimatedWeight = viewModel.estimatedWeight(breed: jenisCattle, gender: genderCattle) { bobotCattle = estimatedWeight }
        }
    }
    
    
    private var estimatedWeightForScan: Double? {
        viewModel.estimatedWeight(breed: jenisCattle, gender: genderCattle)
            ?? bobotCattle
    }

    private var cattleImageForDisplay: UIImage {
        gambarCattle
            ?? UIImage(named: "CattlePlaceholder")
            ?? UIImage()
    }

    private var isSaveDisabled: Bool {
        namaCattle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || jenisCattle == nil
        || genderCattle == nil
        || umurCattle == nil
        || (weightEntryMode == .manual && cattle == nil && bobotCattle == nil)
    }
}

#Preview {
    NavigationStack {
        CattleFormView(
            onScanSession: { _ in },
            viewModel: CattleFormViewModel(calculation: WeightCalculator())
        ) { _ in }
    }
}
