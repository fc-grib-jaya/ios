import SwiftUI

/// Reuses the weight step without opening the add-cattle flow.
struct WeightMeasurementView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CattleWeightProgressViewModel
    @State private var bobotCattle: Double?
    @State private var cattlePhoto: UIImage?
    @State private var scanResult: ScanResult?
    @State private var hasSaved = false
    @State private var isShowingSaveError = false

    let onScanSession: (@escaping (ScanResult?) -> Void) -> Void
    let onSaved: () -> Void

    init(
        viewModel: CattleWeightProgressViewModel,
        onScanSession: @escaping (@escaping (ScanResult?) -> Void) -> Void,
        onSaved: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onScanSession = onScanSession
        self.onSaved = onSaved
    }

    private var canSave: Bool {
        guard let weight = bobotCattle else { return false }
        return weight.isFinite && weight > 0 && weight <= 9_999 && !hasSaved
    }

    var body: some View {
        VStack {
            ThirdPageForm(
                bobotCattle: $bobotCattle,
                cattlePhoto: $cattlePhoto,
                scanResult: $scanResult,
                jenisSapi: .constant(viewModel.cattle.breed),
                genderSapi: .constant(viewModel.cattle.gender),
                isActive: !hasSaved,
                offersScanPhoto: false,
                onScanSession: onScanSession
            )

            Button("Simpan") {
                saveMeasurement()
            }
            .appButtonStyle(.primary)
            .disabled(!canSave)
            .opacity(canSave ? 1 : 0.5)
            .padding(.horizontal, AppSpacing.md)
        }
        .padding(.bottom, AppSpacing.xl)
        .background(AppColor.Surface.canvas)
        .navigationTitle("Ukur Perkembangan")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Gagal menyimpan", isPresented: $isShowingSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Pengukuran bobot gagal disimpan.")
        }
    }

    private func saveMeasurement() {
        guard canSave, let weight = bobotCattle else { return }
        // A new measurement is dated when submitted, never with the acquisition date.
        viewModel.addProgress(
            weight: weight,
            measuredAt: .now,
            chestGirth: scanResult?.girth,
            bodyLength: scanResult?.lengthCM
        )
        guard viewModel.errorMessage == nil else {
            isShowingSaveError = true
            return
        }
        hasSaved = true
        onSaved()
        dismiss()
    }
}
