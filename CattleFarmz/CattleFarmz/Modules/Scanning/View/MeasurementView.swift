import SwiftUI

@MainActor
/// Measurement screen for one captured frame.
///
/// Review the capture, place or edit any landmark, then finish directly.
/// Valid placements advance on release; the final checkmark returns the scan.
struct MeasurementView: View {
    @State private var model: MeasurementViewModel
    @State private var isHelpVisible = false
    private let onExit: () -> Void
    private let onFinish: () -> Void
    private let onRetake: () -> Void
    
    init(
        viewModel: MeasurementViewModel,
        onExit: @escaping () -> Void,
        onFinish: @escaping () -> Void,
        onRetake: @escaping () -> Void
    ) {
        _model = State(initialValue: viewModel)
        self.onExit = onExit
        self.onFinish = onFinish
        self.onRetake = onRetake
    }
    
    var body: some View {
        GeometryReader { geometry in
            let spacing = AppSpacing.md
            let previewSize = CGSize(
                width: geometry.size.width * 728 / 874,
                height: geometry.size.height
            )
            let controlsWidth = max(0, geometry.size.width - previewSize.width - spacing)

            HStack {
                ScanViewport(previewSize: previewSize) { _ in
                    PhotoCanvas(
                        image: model.capture.image,
                        depthImage: model.depthPreview?.image,
                        crop: model.capture.metadata.previewCrop,
                        display: model.display,
                        landmarks: visibleLandmarks,
                        activeID: model.flow.currentID,
                        enabled: model.flow.currentID != nil && !model.isComputing,
                        onMove: model.moveActivePoint,
                        profile: model.result?.profile,
                        depthFrame: model.capture.metadata.depth,
                        onPlacementBegan: model.beginPlacement(on:),
                        onPlacementEnded: model.endPlacement(didMove:)
                    )
                    .overlay {
                        ScanHelpOverlay(isVisible: isHelpVisible) {
                            ScanInstructionCarousel {
                                isHelpVisible = false
                            }
                            .frame(
                                width: min(370, max(1, geometry.size.width - 2 * AppSpacing.md)),
                                height: min(370, max(1, geometry.size.height - 2 * AppSpacing.md))
                            )

                        }
                    }
                }
                .overlay(alignment: .bottomLeading) {
                    Button(action: onRetake) {
                        Text("Retake")
                            .font(AppFont.mediumBody)
                            .padding(10)
//                                .frame(minHeight: 44)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.primary)
                    .accessibilityLabel("Ambil ulang foto sapi")
                    .disabled(model.isPlacing || model.isComputing)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.md)
                }
                .overlay(alignment: .topLeading) {
                    HStack {
                        ScanIconButton(
                            systemImage: "questionmark.circle",
                            accessibilityLabel: "Petunjuk pemindaian",
                            style: isHelpVisible ? .primary : .material
                        ) {
                            isHelpVisible.toggle()
                        }
                        .accessibilityValue(isHelpVisible ? "Ditampilkan" : "Disembunyikan")
                        .padding(.vertical, AppSpacing.md)
                        .padding(.leading, AppSpacing.md)
                        
                        if !isInspectionStage {
                            PointStepProgress(
                                steps: model.steps,
                                activeID: model.flow.currentID,
                                completedIDs: model.flow.reviewedIDs,
                                onSelect: model.selectPoint(at:)
                            )
                            .disabled(model.isPlacing || model.isComputing)
                        }
                    }
                }

                measurementControls
                    .frame(width: controlsWidth, height: previewSize.height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(.black)
        }
        .alert("Pengukuran belum selesai", isPresented: Binding(
            get: { model.finishError != nil },
            set: { if !$0 { model.dismissMessage() } }
        )) {
            Button("OK", role: .cancel) { model.dismissMessage() }
        } message: {
            Text(model.finishError ?? "Perbaiki titik pengukuran, lalu coba lagi.")
        }
        .task { model.prepare() }
        .forceLandscape()
    }

    /// Controls occupy their own column and remain reachable on shorter screens.
    private var measurementControls: some View {
        ScrollView(.vertical) {
            VStack(spacing: AppSpacing.md) {
                if isInspectionStage {
                    ScanIconButton(
                        systemImage: "chevron.right",
                        accessibilityLabel: "Mulai menandai titik",
                        style: model.canBegin ? .primary : .disabled,
                        action: model.beginGuide
                    )
                } else {
                    ScanIconButton(
                        systemImage: "checkmark",
                        accessibilityLabel: model.isComputing ? "Menghitung pengukuran" : "Selesai mengukur",
                        style: model.canFinish || model.isComputing ? .primary : .disabled,
                        action: onFinish
                    )
                    .overlay {
                        if model.isComputing {
                            ProgressView().tint(.white).allowsHitTesting(false)
                        }
                    }
                    .disabled(!model.canFinish)
                }

                CaptureDisplayWheel(selection: $model.display)
                    .disabled(model.isPlacing || model.isComputing)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
        }
        .scrollIndicators(.hidden)
    }

    private var isInspectionStage: Bool { model.flow.stage == .inspection }
    @ViewBuilder private var introduction: some View {
        ScanInstructionCard {
            VStack(alignment: .leading, spacing: 8) {
                switch model.flow.stage {
                case .inspection:
                    Text("Cek foto & depth").font(AppFont.mediumBody)
                    Text(
                        "Pastikan satu sapi terlihat utuh dari samping. Periksa depth pada area dada."
                    )
                    .font(AppFont.caption).foregroundStyle(.secondary)
                case .point(let index):
                    let step = model.steps[index]
                    HStack(spacing: AppSpacing.xxs) {
                        Image(step.number < 3 ? "CattleBodyLength":"CattleChestGirth")
                        VStack (alignment: .leading){
                            Text(step.title).font(AppFont.mediumBody)
                            Text(step.instruction).font(AppFont.caption)
                        }
                    }
                    if model.activePoint != nil && !model.canAdvance {
                        Text(model.currentDepthProblem ?? "Depth titik ini tidak valid. Geser ke area depth yang terbaca.")
                            .font(AppFont.caption)
                            .foregroundStyle(.orange)
                    }

                }
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var visibleLandmarks: [Landmark] {
        switch model.flow.stage {
        case .inspection: return []
        case .point: return model.landmarks
        }
    }

}

#Preview("Cek capture", traits: .fixedLayout(width: 872, height: 402)) {
    MeasurementView(
        viewModel: .preview(.inspection),
        onExit: {},
        onFinish: {},
        onRetake: {}
    )
    
}

#Preview("Titik ukur — checkmark disabled", traits: .fixedLayout(width: 872, height: 402)) {
    
    MeasurementView(
        viewModel: .preview(.point(1)),
        onExit: {},
        onFinish: {},
        onRetake: {}
    )
    
}

#Preview("Siap selesai — checkmark enabled", traits: .fixedLayout(width: 872, height: 402)) {
    
    MeasurementView(
        viewModel: .preview(.readyToFinish),
        onExit: {},
        onFinish: {},
        onRetake: {}
    )
    
}
