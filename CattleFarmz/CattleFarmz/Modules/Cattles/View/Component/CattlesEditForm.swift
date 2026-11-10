//
//  CattlesEditForm.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 07/11/26.
//

import SwiftUI

struct CattleEditValues {
    let name: String
    let dateAcquired: Date
    let breed: CattleBreed
    let gender: CattleGender
    let recordedAge: Int
    let chestGirth: Double?
    let bodyLength: Double?
    let bodyWeight: Double?
    let notes: String?
}

struct CattlesEditForm: View {
    @Environment(\.dismiss) private var dismiss
    let cattle: Cattle
    let onSave: (CattleEditValues) -> String?

    @State private var name: String
    @State private var dateAcquired: Date
    @State private var breed: CattleBreed
    @State private var gender: CattleGender
    @State private var recordedAge: Int
    @State private var chestGirth: Double?
    @State private var bodyLength: Double?
    @State private var bodyWeight: Double?
    @State private var notes: String
    @State private var validationMessage: String?

    init(cattle: Cattle, onSave: @escaping (CattleEditValues) -> String?) {
        self.cattle = cattle
        self.onSave = onSave
        _name = State(initialValue: cattle.name)
        _dateAcquired = State(initialValue: cattle.dateAcquired)
        _breed = State(initialValue: cattle.breed)
        _gender = State(initialValue: cattle.gender)
        _recordedAge = State(initialValue: cattle.recordedAge)
        _chestGirth = State(initialValue: cattle.chestGirth ?? nil)
        _bodyLength = State(initialValue: cattle.bodyLength ?? nil)
        _bodyWeight = State(initialValue: cattle.bodyWeight ?? nil)
        _notes = State(initialValue: cattle.notes ?? "")
    }
    
    var body: some View {
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
                    
                    TextField("Tuliskan Nama Sapi", text: $name)
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
                    
                    Picker("Masukkan Jenis Sapi", selection: $breed) {
                        ForEach(CattleBreed.allCases) { breed in
                            Text(breed.rawValue)
                                .tag(breed)
                        }
                    }
                    .pickerStyle(.menu)
                    .font(AppFont.body)
                    .tint(
                        AppColor.Text.primary
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
                        ForEach(CattleGender.allCases, id: \.self) { item in
                            let isSelected = gender == item

                            Button {
                                gender = item
                            } label: {
                                HStack(spacing: AppSpacing.sm) {
                                    Image(systemName: isSelected
                                          ? "largecircle.fill.circle"
                                          : "circle")
                                    Text(item.rawValue)
                                    Spacer()
                                }
                                .font(AppFont.body)
                                .foregroundStyle(
                                    AppColor.Button.Primary.background
                                )
                                .frame(maxWidth: .infinity)
                                .padding(AppSpacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(
                                            isSelected ? AppColor.Button.Primary.background
                                                .opacity(
                                                    0.2
                                                ) : AppColor.Surface.canvas
                                        )
                                        .stroke(
                                            isSelected ? AppColor.Border.subtle
                                                .opacity(0.2) : AppColor.Border.focus.opacity(0.2)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
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
                            value: $recordedAge,
                            format: .number,
                            prompt: Text("e.g. \"12\"").italic()
                        ) {
                            Text("Usia Sapi (Bulan)")
                        }
                        .keyboardType(.numberPad)
                        .font(AppFont.body)
                        .onChange(of: recordedAge) { _, value in
                            if value > 99 {
                                recordedAge = 99
                            } else if value < 0 {
                                recordedAge = 0
                            }
                        }
                        .padding(AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 23)
                                .fill(AppColor.Surface.canvas)
                        )
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Lingkar Dada")
                            .foregroundStyle(AppColor.Text.primary)
                            .font(AppFont.body)
                        
                        HStack {
                            TextField(
                                value: $chestGirth,
                                format: .number,
                                prompt: Text("e.g. \"604,19\" cm").italic()
                            ) {
                                Text("Lingkar Dada (cm)")
                            }
                            .keyboardType(.decimalPad)
                            
                            Text("cm")
                                .foregroundStyle(AppColor.Text.primary)
                        }
                        .padding(AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 23)
                                .fill(AppColor.Surface.canvas)
                        )
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Panjang Badan")
                            .foregroundStyle(AppColor.Text.primary)
                            .font(AppFont.body)
                        
                        HStack {
                            TextField(
                                value: $bodyLength,
                                format: .number,
                                prompt: Text("e.g. \"604,19\" cm").italic()
                            ) {
                                Text("Panjang Badan (cm)")
                            }
                            .keyboardType(.decimalPad)
                            
                            Text("cm")
                                .foregroundStyle(AppColor.Text.primary)
                        }
                        .padding(AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 23)
                                .fill(AppColor.Surface.canvas)
                        )
                    }
                    
                    
                    VStack(alignment: .leading) {
                        HStack (spacing: 1) {
                            Text("Bobot")
                                .foregroundStyle(AppColor.Text.primary)
                            Text("*")
                                .foregroundStyle(Color.red)
                        }
                        .font(AppFont.body)
                        
                        HStack {
                            TextField(
                                value: $bodyWeight,
                                format: .number,
                                prompt: Text("e.g. \"604,19\" kg").italic()
                            ) {
                                Text("Bobot Sapi (kg)")
                            }
                            .keyboardType(.decimalPad)
                            
                            Text("kg")
                                .foregroundStyle(AppColor.Text.primary)
                        }
                        .padding(AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 23)
                                .fill(AppColor.Surface.canvas)
                        )
                    }
                    
                    VStack (alignment: .leading){
                        Text("Catatan")
                            .font(AppFont.body)
                            .foregroundStyle(AppColor.Text.primary)
                        
                        TextField(
                            text: $notes,
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
                    
                }

                if let validationMessage {
                    Text(validationMessage)
                        .font(AppFont.caption)
                        .foregroundStyle(.red)
                }
            }
            .padding(AppSpacing.md)
        }
        
        .navigationTitle("Edit Sapi")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Simpan") {
                    save()
                }
            }
        }
    }
    
    private func save() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            validationMessage = "Nama sapi wajib diisi."
            return
        }

        guard recordedAge >= 0 else {
            validationMessage = "Umur harus berupa angka 0 atau lebih."
            return
        }

        guard let bodyWeight, bodyWeight.isFinite, bodyWeight > 0 else {
            validationMessage = "Bobot sapi wajib diisi dan harus lebih dari 0."
            return
        }

        let values = CattleEditValues(
            name: name,
            dateAcquired: dateAcquired,
            breed: breed,
            gender: gender,
            recordedAge: recordedAge,
            chestGirth: chestGirth,
            bodyLength: bodyLength,
            bodyWeight: bodyWeight,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
        )

        if let error = onSave(values) {
            validationMessage = error
        } else {
            dismiss()
        }
    }
    
    private func parseOptionalPositiveNumber(_ value: String, fieldName: String) -> Double?? {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else {
            return .some(nil)
        }

        guard let number = Double(trimmedValue), number.isFinite, number > 0 else {
            validationMessage = "\(fieldName) harus berupa angka lebih dari 0."
            return nil
        }

        return .some(number)
    }
    
    nonisolated private static func numberString(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...2)))
    }
}

#Preview {
    NavigationStack{
        CattlesEditForm(cattle: Cattle.samples[1]) { _ in
            nil
        }
    }
}
