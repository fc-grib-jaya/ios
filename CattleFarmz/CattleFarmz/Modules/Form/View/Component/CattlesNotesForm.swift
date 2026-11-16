//
//  CattlesNotesForm.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 16/11/26.
//

import SwiftUI

struct CattlesNotesForm: View {
    @Binding var notes: String?

    private var notesText: Binding<String> {
        Binding(
            get: { notes ?? "" },
            set: { notes = $0.isEmpty ? nil : $0 }
        )
    }
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack {
            Text("Tambahkan catatan")
                .font(AppFont.formTitle)
                .foregroundStyle(AppColor.Primitive.Secondary.shade950)
                .multilineTextAlignment(.center)
                .padding(.vertical, AppSpacing.xl)

            Spacer()
            
            VStack {
                HStack {
                    TextField(
                        "Catatan",
                        text: notesText,
                        prompt: Text("Contoh: “Kandang ada di pojok.”").italic()
                    )
                        .font(AppFont.body)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .notes)

                    if !(notes ?? "").isEmpty {
                        Button {
                            notes = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(AppColor.Primitive.Neutral.shade300)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Hapus catatan")
                    }
                }
                .padding(.vertical, AppSpacing.xxs)
                .padding(.horizontal, AppSpacing.lg)

                Divider()
                    .overlay(AppColor.Text.primary)
                    .padding(.horizontal, AppSpacing.lg)
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.md)
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
    }
}

#Preview {
    @Previewable @State var notes: String?
    
    CattlesNotesForm(notes: $notes)
}
