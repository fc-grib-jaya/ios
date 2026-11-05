//
//  SapiFormView.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 04/11/26.
//

import SwiftUI
import UIKit

struct SapiFormView: View {
    @State private var namaSapi = ""
    @State private var jenisSapi: CattleBreed?
    @State private var genderSapi: CattleGender?
    @State private var umurSapi: Int?
    @State private var bobotSapi: Double?
    @State private var gambarSapi: UIImage?
    @State private var catatan = ""
    
    @Environment(\.dismiss) var cancel
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
            AppColor.background
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack (alignment: .leading, spacing: AppSpacing.medium){
                    VStack (alignment: .leading){
                        HStack (spacing: 1){
                            Text("Nama Sapi")
                                .foregroundStyle(AppColor.textPrimary)
                            Text("*")
                                .foregroundStyle(AppColor.textRequired)
                        }
                        .font(AppFont.body)
                        
                        TextField("Tuliskan Nama Sapi", text: $namaSapi)
                            .font(AppFont.body)
                            .autocorrectionDisabled()
                            .padding(AppSpacing.medium)
                            .background(
                                RoundedRectangle(cornerRadius: 23)
                                    .fill(AppColor.surface)
                            )
                    }
                    
                    VStack (alignment: .leading){
                        HStack(spacing: 1) {
                            Text("Jenis Sapi")
                                .foregroundStyle(AppColor.textPrimary)
                            Text("*")
                                .foregroundStyle(AppColor.textRequired)
                        }
                        .font(AppFont.body)
                        
                        Picker("Masukkan Jenis Sapi", selection: $jenisSapi) {
                            Text("Masukkan Jenis Sapi")
                                .tag(nil as CattleBreed?)
                            
                            ForEach(CattleBreed.allCases) { breed in
                                Text(breed.rawValue)
                                    .tag(breed)
                            }
                        }
                        .pickerStyle(.menu)
                        .font(AppFont.body)
                        .tint(jenisSapi == nil ? AppColor.textSecondary.opacity(0.5) : AppColor.textPrimary)
                        .padding(AppSpacing.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 23)
                                .fill(AppColor.surface)
                        )
                    }
                    
                    VStack (alignment: .leading){
                        HStack (spacing: 1) {
                            Text("Jenis Kelamin Sapi")
                                .foregroundStyle(AppColor.textPrimary)
                            Text("*")
                                .foregroundStyle(AppColor.textRequired)
                        }
                        .font(AppFont.body)
                        
                        HStack(spacing: AppSpacing.medium) {
                            ForEach(CattleGender.allCases, id: \.self) { gender in
                                let isSelected = genderSapi == gender

                                Button {
                                    genderSapi = gender
                                } label: {
                                    HStack(spacing: AppSpacing.small) {
                                        Image(systemName: isSelected
                                              ? "largecircle.fill.circle"
                                              : "circle")
                                        Text(gender.rawValue)
                                        Spacer()
                                    }
                                    .font(AppFont.body)
                                    .foregroundStyle(
                                        isSelected ? AppColor.primary : AppColor.textPrimary
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(AppSpacing.xm)
                                    .background(
                                        RoundedRectangle(cornerRadius: 30)
                                            .fill(isSelected ? AppColor.primary.opacity(0.2) : AppColor.surface)
                                            .stroke(isSelected ? AppColor.primary : AppColor.primary.opacity(0.2))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    VStack (alignment: .leading){
                        HStack (spacing: 1) {
                            Text("Usia Sapi (Bulan)")
                                .foregroundStyle(AppColor.textPrimary)
                            Text("*")
                                .foregroundStyle(AppColor.textRequired)
                        }
                        .font(AppFont.body)
                        
                        TextField(
                            value: $umurSapi,
                            format: .number,
                            prompt: Text("e.g. \"12\"").italic()
                        ) {
                            Text("Usia Sapi (Bulan)")
                        }
                        .keyboardType(.numberPad)
                        .font(AppFont.body)
                        .onChange(of: umurSapi) { _, value in
                            guard let value else { return }

                            if value > 99 {
                                umurSapi = 99
                            } else if value < 0 {
                                umurSapi = 0
                            }
                        }
                        .padding(AppSpacing.medium)
                        .background(
                            RoundedRectangle(cornerRadius: 23)
                                .fill(AppColor.surface)
                        )
                    }
                    
                    Text("Bobot dan Foto Sapi")
                        .foregroundStyle(AppColor.textPrimary)
                        .font(AppFont.body)
                    VStack (alignment: .leading){
                        
                        HStack(spacing: AppSpacing.small) {
                            weightModeButton("Isi Bobot", mode: .manual)
                            weightModeButton("Estimasi Bobot", mode: .camera)
                        }
                        .padding(.bottom, AppSpacing.small)
                        
                        if (weightEntryMode == .manual) {
                            Text("Masukkan bobot secara manual, lalu ambil foto untuk profil sapi.")
                                .font(AppFont.caption)
                                .padding(.bottom, AppSpacing.small)
                            
                            HStack (spacing: 1) {
                                Text("Bobot")
                                    .foregroundStyle(AppColor.textPrimary)
                                Text("*")
                                    .foregroundStyle(AppColor.textRequired)
                            }
                            .font(AppFont.body)
                            
                            HStack {
                                TextField(
                                    value: $bobotSapi,
                                    format: .number,
                                    prompt: Text("e.g. \"604,19\"").italic()
                                ) {
                                    Text("Bobot Sapi (kg)")
                                }
                                .keyboardType(.decimalPad)
                                
                                Text("kg")
                                    .foregroundStyle(AppColor.textPrimary)
                            }
                            .padding(AppSpacing.xm)
                            .background(
                                RoundedRectangle(cornerRadius: 23)
                                    .fill(AppColor.surface)
                            )
                            
                            //Camera
                            Button {
                                isShowingCamera = true
                            } label: {
                                VStack(spacing: AppSpacing.medium) {
                                    if let gambarSapi {
                                        Image(uiImage: gambarSapi)
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
                                .foregroundStyle(AppColor.textSecondary.opacity(0.5))
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 23)
                                        .fill(AppColor.surface)
                                        .stroke(AppColor.textSecondary, style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
                                )
                            }
                            .buttonStyle(.plain)
                        } else {
                            Text("Estimasi bobot dengan kamera. Foto yang sama digunakan sebagai foto profil sapi.")
                                .font(AppFont.caption)
                                .padding(.bottom, AppSpacing.small)
                            
                            HStack {
                                Text("\(Image(systemName: "exclamationmark.circle")) Pilih jenis sapi untuk mulai estimasi.")
                                    .font(AppFont.caption)
                                Spacer()
                            }
                            .padding(AppSpacing.xm)
                            .background(
                                RoundedRectangle(cornerRadius: 23)
                                    .fill(AppColor.surface)
                            )
                            
                            Button {
                                // Lidar
                            } label: {
                                VStack {
                                    Image(systemName: "camera.on.rectangle.fill")
                                        .font(AppFont.largeTitle)
                                    Text("Estimasi bobot dan foto sapi")
                                        .italic()
                                        .lineLimit(1)
                                }
                                .font(AppFont.body)
                                .foregroundStyle(AppColor.textSecondary.opacity(0.5))
                                .padding(.vertical, AppSpacing.xl)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 23)
                                        .fill(AppColor.surface)
                                        .stroke(AppColor.textSecondary, style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        
                    }
                    .font(AppFont.body)
                    .padding(AppSpacing.medium)
                    .background(
                        RoundedRectangle(cornerRadius: 23)
                            .fill(AppColor.surface.opacity(0.5))
                    )
                    
                    VStack (alignment: .leading){
                        Text("Catatan")
                            .font(AppFont.body)
                            .foregroundStyle(AppColor.textPrimary)
                        
                        TextField(
                            text: $catatan,
                            prompt: Text("e.g., \"Letak kandang ada di pojok.\"").italic()
                        ) {
                            Text("Catatan")
                        }
                            .font(AppFont.body)
                            .autocorrectionDisabled()
                            .padding(AppSpacing.medium)
                            .background(
                                RoundedRectangle(cornerRadius: 23)
                                    .fill(AppColor.surface)
                            )
                    }
                    .padding(.bottom, AppSpacing.large)
                    
                    Button {
                        guard let breed = jenisSapi,
                              let gender = genderSapi else {
                            return
                        }

                        guard let umurSapi else { return }

                        Task {
                            do {
                                try await onSave(namaSapi, .now, breed, gender, umurSapi, bobotSapi, gambarSapi, catatan)
                                cancel()
                            } catch {
                                saveError = error.localizedDescription
                            }
                        }
                    } label: {
                        Text("Simpan Data")
                            .font(AppFont.body)
                            .foregroundStyle(AppColor.onPrimary)
                            .padding(.vertical, AppSpacing.xm)
                            .frame(maxWidth: .infinity)
                            .glassEffect(.regular.tint(AppColor.primary))
                    }
                    .disabled(
                        namaSapi.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        || jenisSapi == nil
                        || genderSapi == nil
                        || umurSapi == nil
                        || (weightEntryMode == .manual && bobotSapi == nil)
                    )
                }
                .padding()
            }
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            CameraPicker(
                image: $gambarSapi,
                isPresented: $isShowingCamera
            )
            .ignoresSafeArea()
        }
        .navigationTitle("Tambah Sapi")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func weightModeButton(
        _ title: String,
        mode: WeightEntryMode
    ) -> some View {
        let isSelected = weightEntryMode == mode

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                weightEntryMode = mode
            }
        } label: {
            Text(title)
                .font(AppFont.body)
                .foregroundStyle(AppColor.onPrimary)
                .padding(.vertical, AppSpacing.medium)
                .frame(maxWidth: .infinity)
                .glassEffect(.regular.tint(isSelected ? AppColor.primary : AppColor.primary.opacity(0.3)))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SapiFormView { _, _, _, _, _, _, _, _ in }
    }
}
