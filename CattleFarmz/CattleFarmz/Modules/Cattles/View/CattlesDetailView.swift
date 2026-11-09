//
//  CattlesDetailView.swift
//  CattleFarmz
//

import SwiftUI
import UIKit

struct CattlesDetailView: View {
    @State private var viewModel: CattlesViewModel
    private let cattleID: UUID?
    @State private var cattle: Cattle?
    @State private var isEditing = false
    @State private var errorMessage: String?

    init(cattleID: String, viewModel: CattlesViewModel) {
        self.cattleID = UUID(uuidString: cattleID)
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            if let cattle {
                let bodyWeight = cattle.bodyWeight ?? viewModel.cattleWeight(for: cattle)

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    if let imageData = cattle.cattleImage,
                       let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 180, alignment: .top)
                            .clipped()
                            .cornerRadius(AppSpacing.Card.compact)
                    } else {
                        Image("CattlePlaceholder")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 180, alignment: .top)
                            .clipped()
                            .cornerRadius(AppSpacing.Card.compact)
                    }

                    CattlesDetailCard(
                        name: cattle.name,
                        breed: cattle.breed,
                        gender: cattle.gender,
                        age: cattle.recordedAge,
                        weight: bodyWeight,
                        updatedDate: cattle.dateAcquired,
                        chestGirth: cattle.chestGirth,
                        bodyLength: cattle.bodyLength,
                        notes: cattle.notes
                    )

                    Text("Terakhir disimpan: \(formatDate(cattle.dateAcquired))")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.Primitive.Neutral.shade500)
                }
                .padding(AppSpacing.md)
            } else {
                ContentUnavailableView(
                    "Sapi Tidak Ditemukan",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Data sapi tidak tersedia.")
                )
            }
        }
        .navigationTitle(cattle?.name ?? "Detail Sapi")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if cattle != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        isEditing = true
                    }
                }
            }
        }
        .task {
            await loadCattle()
        }
        .sheet(isPresented: $isEditing) {
            if let cattle {
                NavigationStack {
                    CattlesEditForm(cattle: cattle) { values in
                        save(values, for: cattle)
                    }
                }
            }
        }
        .alert("Gagal Menyimpan", isPresented: errorAlertIsPresented) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "Perubahan tidak dapat disimpan.")
        }
    }

    private var errorAlertIsPresented: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )
    }

    private func loadCattle() async {
        guard let cattleID else { return }

        await viewModel.load()
        cattle = viewModel.items.first { $0.id == cattleID }
    }

    private func save(_ values: CattleEditValues, for cattle: Cattle) -> String? {
        do {
            try viewModel.update(
                for: cattle,
                name: values.name,
                dateAcquired: values.dateAcquired,
                breed: values.breed,
                gender: values.gender,
                recordedAge: values.recordedAge,
                chestGirth: values.chestGirth,
                bodyLength: values.bodyLength,
                bodyWeight: values.bodyWeight,
                notes: values.notes
            )
            self.cattle = viewModel.items.first { $0.id == cattle.id }
            return nil
        } catch {
            return "Periksa kembali data yang dimasukkan."
        }
    }
}

#Preview {
    NavigationStack {
        CattlesDetailView(
            cattleID: Cattle.samples[2].id.uuidString,
            viewModel: CattlesViewModel(
                repository: MockCattleRepository(),
                calculation: WeightCalculator()
            )
        )
    }
}
