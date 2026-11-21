//
//  CattleWeightProgressView.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 21/11/26.
//

import SwiftUI
import SwiftData

struct CattleWeightProgressView: View {
    @State private var viewModel: CattleWeightProgressViewModel
    @State private var inputWeight: Double?

    init(cattle: Cattle, modelContext: ModelContext) {
        _viewModel = State(
            initialValue: CattleWeightProgressViewModel(
                cattle: cattle,
                modelContext: modelContext
            )
        )
    }

    var body: some View {
        List {
            Section("Bobot terkini") {
                if let weight = viewModel.currentWeight {
                    Text("\(weight.formatted()) kg")
                } else {
                    Text("Belum ada bobot")
                }

                if let gain = viewModel.totalWeightGain {
                    Text("Perubahan bobot: \(gain.formatted()) kg")
                }
            }

            Section("Tambah pengukuran") {
                TextField(
                    "Bobot (kg)",
                    value: $inputWeight,
                    format: .number
                )
                .keyboardType(.decimalPad)

                Button("Simpan") {
                    guard let weight = inputWeight else { return }

                    viewModel.addProgress(
                        weight: weight
                    )

                    if viewModel.errorMessage == nil {
                        inputWeight = nil
                    }
                }
                .disabled(inputWeight == nil)
            }

            Section("Riwayat bobot") {
                ForEach(viewModel.progress.reversed()) { entry in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(
                                entry.measuredAt,
                                format: .dateTime.day().month().year()
                            )

//                            Text(entry.source.rawValue)
//                                .font(.caption)
//                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("\(entry.weight.formatted()) kg")
                    }
                    .swipeActions {
                        Button("Hapus", role: .destructive) {
                            viewModel.removeProgress(entry)
                        }
                    }
                }
            }

            if let message = viewModel.errorMessage {
                Text(message)
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle("Progress Bobot")
    }
}
#Preview {
    CattleWeightProgressPreview()
        .modelContainer(
            for: [Cattle.self, CattleWeightProgress.self],
            inMemory: true
        )
}

private struct CattleWeightProgressPreview: View {
    @Environment(\.modelContext) private var modelContext

    private let cattle = Cattle(
        name: "Preview Cow",
        dateAcquired: .now,
        breed: .bali,
        gender: .female,
        recordedAge: 12
    )

    var body: some View {
        CattleWeightProgressView(
            cattle: cattle,
            modelContext: modelContext
        )
    }
}
