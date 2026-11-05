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
                VStack (spacing: AppSpacing.medium){
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
                        
                        Picker("Masukkan Jenis Kelamin Sapi", selection: $genderSapi) {
                            Text("Masukkan Jenis Kelamin Sapi")
                                .tag(nil as CattleGender?)
                            
                            ForEach(CattleGender.allCases) { gender in
                                Text(gender.rawValue)
                                    .tag(gender)
                            }
                        }
                        .pickerStyle(.menu)
                        .font(AppFont.body)
                        .tint(genderSapi == nil ? AppColor.textSecondary.opacity(0.5) : AppColor.textPrimary)
                        .padding(AppSpacing.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 23)
                                .fill(AppColor.surface)
                        )
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

                            if value > 36 {
                                umurSapi = 36
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
                    
                    VStack (alignment: .leading){
                        HStack(spacing: AppSpacing.small) {
                            weightModeButton("Isi Bobot", mode: .manual)
                            weightModeButton("Estimasi Bobot", mode: .camera)
                        }
                        .padding(.bottom, AppSpacing.small)
                        
                        if (weightEntryMode == .manual) {
                            HStack {
                                TextField(
                                    value: $bobotSapi,
                                    format: .number,
                                    prompt: Text("e.g. \"604,19\"").italic()
                                ) {
                                    Text("Bobot Sapi (kg)")
                                }
                                .keyboardType(.decimalPad)
                                
                                HStack (spacing: 1) {
                                    Text("kg")
                                        .foregroundStyle(AppColor.textPrimary)
                                    Text("*")
                                        .foregroundStyle(AppColor.textRequired)
                                }
                            }
                            .padding(AppSpacing.medium)
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
                                            .padding(.vertical, AppSpacing.large)
                                    }
                                }
                                .font(AppFont.body)
                                .foregroundStyle(AppColor.textSecondary.opacity(0.5))
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 23)
                                        .fill(AppColor.surface)
                                )
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button {
                                // Lidar
                            } label: {
                                VStack(spacing: AppSpacing.medium) {
                                    Image(systemName: "camera.on.rectangle.fill")
                                        .font(AppFont.largeTitle)
                                    HStack(spacing: 1) {
                                        Text("Estimasi bobot dengan kamera")
                                            .italic()
                                            .lineLimit(1)
                                        Text("*")
                                            .foregroundStyle(AppColor.textRequired)
                                    }
                                }
                                .font(AppFont.body)
                                .foregroundStyle(AppColor.textSecondary.opacity(0.5))
                                .padding(.vertical, AppSpacing.xxl)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 23)
                                        .fill(AppColor.surface)
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
                    .padding(.bottom, AppSpacing.small)
                }
                .padding()
            }

//            if isShowingCamera {
//                CameraPicker(
//                    image: $gambarSapi,
//                    isPresented: $isShowingCamera
//                )
//                .ignoresSafeArea()
//                .zIndex(1)
//            }
        }
        .sheet(isPresented: $isShowingCamera) {
            CameraPicker(
                image: $gambarSapi,
                isPresented: $isShowingCamera
            )
            .ignoresSafeArea()
        }
        .navigationTitle("Tambah Sapi")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    cancel()
                } label: {
                    Image(systemName: "xmark")
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Finish", systemImage: "checkmark") {
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
                }
                .tint(AppColor.primary)
                .disabled(
                    namaSapi.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    || jenisSapi == nil
                    || genderSapi == nil
                    || umurSapi == nil
                    || (weightEntryMode == .manual && bobotSapi == nil)
                )
            }
        })
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
