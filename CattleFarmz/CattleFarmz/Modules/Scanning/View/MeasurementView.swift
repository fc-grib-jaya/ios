import SwiftUI

@MainActor
/// Measurement screen for one captured frame.
///
/// A three-part wizard: Cek capture → Titik ukur → Hasil. The leading back
/// button moves one stage back and is hidden on the first stage. The trailing
/// blue button advances. Retaking the photo is a first-stage action.
struct MeasurementView: View {
    @State private var model: MeasurementViewModel
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
            let previewWidth = min(
                geometry.size.width * 734 / 874,
                max(1, geometry.size.width - 2 * AppSpacing.lg)
            )
            let previewSize = CGSize(width: previewWidth, height: geometry.size.height)
            
            ZStack {
                PhotoCanvas(
                    image: model.capture.image,
                    depthImage: model.depthPreview?.image,
                    crop: model.capture.metadata.previewCrop,
                    display: model.display,
                    landmarks: visibleLandmarks,
                    activeID: model.flow.currentID,
                    enabled: model.flow.currentID != nil,
                    onMove: model.moveActivePoint,
                    profile: model.result?.profile,
                    depthFrame: model.capture.metadata.depth,
                    onPlacementEnded: model.analyzePlacement
                )
                //                    .frame(
                //                        height: min(490, max(300, geometry.size.height * 0.52))
                //                    )
                .frame(width: previewSize.width, height: previewSize.height)
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .overlay (alignment: .bottom){
                    introduction
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.bottom, AppSpacing.lg)
                }
                .overlay (alignment: .trailing) {
                    displayPicker
                }
                //                if model.depthLoading {
                //                    ProgressView("Menyiapkan tampilan depth…")
                //                }
                //                if model.display != .photo, let preview = model.depthPreview
                //                {
                //                    DepthLegend(visualization: preview.visualization)
                //                }
                //                if model.activePoint != nil {
                //                    HStack {
                //                        Button("←") { model.nudge(dx: -1, dy: 0) }.accessibilityLabel("Geser kiri satu piksel depth")
                //                        Button("↑") { model.nudge(dx: 0, dy: -1) }.accessibilityLabel("Geser atas satu piksel depth")
                //                        Button("↓") { model.nudge(dx: 0, dy: 1) }.accessibilityLabel("Geser bawah satu piksel depth")
                //                        Button("→") { model.nudge(dx: 1, dy: 0) }.accessibilityLabel("Geser kanan satu piksel depth")
                //                    }.buttonStyle(.bordered).controlSize(.large)
                //                }
                //                if !model.analysisText.isEmpty {
                //                    DisclosureGroup("Detail stride dan sensitivitas") { Text(model.analysisText).font(.caption) }
                //                }
                //                content
                //                details
            }
            //            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay (alignment: .topTrailing) {
                //            ToolbarItem(placement: .topBarTrailing) {
                //                Button("Keluar", systemImage: "rectangle.portrait.and.arrow.right") {
                //                    onExit()
                //                }
                //                .tint(.red)
                //                .accessibilityHint("Kembali ke halaman sebelum kamera")
                //            }
                if model.flow.stage != .results {
                    Button {
                        advanceStage()
                    } label : {
                        //                        Label("Lanjut", systemImage: "checkmark")
                        Image(systemName: "checkmark")
                            .frame(width: 44, height: 44)
                            .background(
                                canAdvanceStage
                                    ? AppColor.Primitive.Primary.shade500
                                    : AppColor.Primitive.Neutral.shade300,
                                in: Circle()
                            )
                    }
                    .foregroundStyle(
                        canAdvanceStage
                            ? AppColor.Primitive.Neutral.shade50
                            : AppColor.Primitive.Neutral.shade600
                    )
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xxl)
                    .accessibilityLabel("Lanjut ke langkah berikutnya")
                    //                    .tint(.blue)
                    .disabled(!canAdvanceStage)
                    //                    .labelStyle(.titleOnly)
                    
                } else {
                    Button {
                        onFinish()
                    } label: {
                        Image(systemName: "checkmark")
                            .frame(width: 44, height: 44)
                            .background(AppColor.Primitive.Primary.shade500, in: Circle())
                    }
                    .foregroundStyle(AppColor.Primitive.Neutral.shade50)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xxl)
                    
                    
                }
            }
            .overlay (alignment: .topLeading){
                if model.flow.stage == .inspection {
                    Button(action: onRetake) {
//                        Label("Ambil ulang", systemImage: "arrow.counterclockwise")
                        Image(systemName: "chevron.left")
//                            .font(AppFont.mediumBody)
//                            .padding(.horizontal, AppSpacing.md)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .tint(.primary)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xxl)
                    .accessibilityLabel("Ambil ulang foto sapi")
                } else {
                    Button {
                        model.previous()
                    } label: {
                        Image(systemName: "chevron.left")
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .tint(.primary)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xxl)
                    .accessibilityLabel("Kembali ke langkah sebelumnya")
                    
                }
            }
            .overlay(alignment: .bottomLeading) {
                Button {} label: {
                    Image(systemName: "questionmark.circle")
                        .frame(width: 44, height: 44)
                        .background(AppColor.Primitive.Primary.shade500, in: Circle())
                }
                .foregroundStyle(AppColor.Primitive.Neutral.shade50)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xxl)
                .accessibilityLabel("Petunjuk pemindaian")
            }
        }
        //        .navigationTitle("Periksa profil sapi")
        //        .navigationBarTitleDisplayMode(.inline)
        //        .navigationSubtitle("Estimasi dengan kamera LiDAR")
        .task { model.prepare() }
        .forceLandscape()
    }
    
    private var canAdvanceStage: Bool {
        switch model.flow.stage {
        case .inspection:
            model.canBegin
        case .point:
            model.canAdvance
        case .results:
            false
        }
    }
    
    private func advanceStage() {
        switch model.flow.stage {
        case .inspection:
            model.beginGuide()
        case .point:
            model.advance()
        case .results:
            break
        }
    }
    
    @ViewBuilder private var introduction: some View {
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
//                    GuideIllustration(step: step)
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
            case .results:
                Text("Hasil pengukuran").font(AppFont.mediumBody)
                Text(
                    "Periksa titik dan kelayakan depth sebelum memakai estimasi ini."
                )
                .font(AppFont.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 50))
    }
    
    /// Cek capture is step 1, each point is one step, and results is the last.
    private var wizardStep: Int {
        switch model.flow.stage {
        case .inspection: 1
        case .point(let index): index + 2
        case .results: model.steps.count + 2
        }
    }
    
    private var wizardStepTotal: Int {
        model.steps.count + 2
    }
    
    private var displayPicker: some View {
        CaptureDisplayWheel(selection: $model.display)
    }
    
    private var visibleLandmarks: [Landmark] {
        switch model.flow.stage {
        case .inspection: return []
        case .point(let index):
            let visible = Set(model.steps.prefix(index + 1).map(\.id))
            return model.landmarks.filter { visible.contains($0.id) }
        case .results: return model.landmarks
        }
    }
    
    @ViewBuilder private var content: some View {
        switch model.flow.stage {
        case .inspection:
            if let error = model.depthError {
                Label(error, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
            } else if !model.depthLoading && !model.canBegin {
                Text(
                    "Depth belum cukup terbaca. Ambil ulang dari posisi yang lebih jelas."
                )
                .foregroundStyle(.orange)
            } else {
                Text(
                    "Area abu-abu berarti depth visual kurang terbaca. Periksa area tubuh dan titik ukur."
                )
                .font(.footnote).foregroundStyle(.secondary)
            }
        case .point:
            if let step = model.currentStep, model.activePoint != nil {
                if let problem = model.currentDepthProblem {
                    Label(problem, systemImage: "exclamationmark.circle")
                        .foregroundStyle(.orange)
                } else {
                    Label(
                        step.id.hasPrefix("chest") ? "Depth tersedia · batas profil ditandai" : "Depth tersedia pada titik \(step.number)",
                        systemImage: "mappin.circle"
                    )
                    .foregroundStyle(.teal)
                }
                Text("Geser titik atau ketuk posisi baru jika belum tepat.")
                    .font(.footnote).foregroundStyle(.secondary)
                Button("Hapus titik ini") { model.clearCurrentPoint() }
            } else if let step = model.currentStep {
                Label(
                    "Ketuk foto untuk menaruh titik \(step.number).",
                    systemImage: "hand.tap"
                )
                .foregroundStyle(.teal)
            }
        case .results:
            if let result = model.result {
                resultCard(result)
                if let message = model.message {
                    Label(message, systemImage: "exclamationmark.circle")
                        .font(.callout).foregroundStyle(.orange)
                }
                if result.girth == nil {
                    Button("Perbaiki titik dada") { model.editPoints(from: 2) }
                        .buttonStyle(.bordered)
                }
            } else {
                Label(
                    model.message
                    ?? "Ukuran belum dapat dihitung. Periksa titik atau ambil ulang.",
                    systemImage: "exclamationmark.triangle"
                ).foregroundStyle(.orange)
            }
            Button("Koreksi titik dari awal") { model.editPoints() }
                .buttonStyle(.bordered)
        }
    }
    
    private var details: some View {
        DisclosureGroup("Detail pengukuran") {
            VStack(alignment: .leading, spacing: 8) {
                if let preview = model.depthPreview {
                    let rawFraction =
                    Double(model.rawValidCount)
                    / Double(
                        max(1, model.capture.metadata.depth.meters.count)
                    )
                    Text(
                        "Depth visual valid pada \(Int(preview.visualization.validFraction * 100))% frame. Depth mentah untuk hitungan valid pada \(Int(rawFraction * 100))% frame."
                    )
                    Text(
                        "Depth warna dan profil memakai data mentah dari frame yang sama."
                    )
                }
                if let point = model.activePoint,
                   let xyz = try? model.capture.metadata.depth.point(
                    at: point.point
                   )
                {
                    Text(
                        "Depth titik aktif: \(xyz.z.formatted(.number.precision(.fractionLength(2)))) m"
                    )
                }
                Text(
                    "Profil dada membaca piksel raw depth sepanjang garis. Celah dan lonjakan depth memutus segmen."
                )
            }.font(.caption).padding(.top, 8)
        }
    }
    
    private func resultCard(_ result: MeasurementResult) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Estimasi eksperimental · belum tervalidasi")
                .font(.caption).foregroundStyle(.orange)
            LabeledContent(
                "Panjang badan",
                value:
                    "\(result.lengthCM.formatted(.number.precision(.fractionLength(1)))) cm"
            )
            if let profile = result.profile {
                LabeledContent("Lingkar bagian terbaca", value: profile.lengthCM.map {
                    $0.formatted(.number.precision(.fractionLength(1))) + " cm"
                } ?? "Belum tersedia")
                LabeledContent("Lingkar Dada", value: profile.lengthCM.map {
                    ($0*2).formatted(.number.precision(.fractionLength(1))) + " cm"
                } ?? "Belum tersedia")
                //                Text("\(profile.samples.filter { $0.point != nil }.count)/\(profile.samples.count) piksel terbaca · \(profile.segmentLengthsCM.count) segmen")
                //                Text("Hijau: tersambung · merah: piksel ditolak · jingga: awal segmen/putus. Garis kuning hanya panduan penandaan.")
                //                    .font(.caption)
                //                Text("Raw depth · confidence ≥1 · 0,25–5 m · putus jika lonjakan ≥8 cm. Panjang ini belum merupakan lingkar dada.")
                //                    .font(.caption)
                //                ForEach(Array(profile.segmentLengthsCM.enumerated()), id: \.offset) { index, length in
                //                    Text("Segmen \(index + 1): \(length.formatted(.number.precision(.fractionLength(1)))) cm")
                //                }
                //                DisclosureGroup("Piksel dan celah profil") {
                //                    ForEach(Array(profile.samples.enumerated()), id: \.offset) { _, sample in
                //                        VStack(alignment: .leading) {
                //                            Text("(\(sample.x), \(sample.y)) · z \(sample.depth) m · confidence \(sample.confidence)")
                //                            Text("\(sample.connectedToPrevious ? "Terhubung" : "Awal/putus") · \(sample.status)")
                //                            if let p = sample.point {
                //                                Text("XYZ: \(p.x), \(p.y), \(p.z) m")
                //                            }
                //                        }.font(.caption).frame(maxWidth: .infinity, alignment: .leading)
                //                    }
                //                }
            }
//            if let girth = result.girth {
//                LabeledContent(
//                    "Lingkar dada",
//                    value:
//                        "\(girth.centimeters.formatted(.number.precision(.fractionLength(1)))) cm"
//                )
//                Text(
//                    "\(girth.validSamples) sampel · residu \(girth.residualMeters.formatted(.number.precision(.fractionLength(3)))) m"
//                )
//                .font(.caption).foregroundStyle(.secondary)
//            }
//            if let weight = result.weightKG {
//                LabeledContent(
//                    "Bobot Winter",
//                    value:
//                        "≈ \(weight.formatted(.number.precision(.fractionLength(0)))) kg"
//                )
//            }
        }.padding().frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview("Cek capture") {
    MeasurementView(
        viewModel: .preview(.inspection),
        onExit: {},
        onFinish: {},
        onRetake: {}
    )
    
}

#Preview("Titik ukur") {
    
    MeasurementView(
        viewModel: .preview(.point(1)),
        onExit: {},
        onFinish: {},
        onRetake: {}
    )
    
}

#Preview("Hasil") {
    
    MeasurementView(
        viewModel: .preview(.results),
        onExit: {},
        onFinish: {},
        onRetake: {}
    )
    
}
