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
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    introduction
                    displayPicker
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
                    .frame(
                        height: min(490, max(300, geometry.size.height * 0.52))
                    )
                    if model.depthLoading {
                        ProgressView("Menyiapkan tampilan depth…")
                    }
                    if model.display != .photo, let preview = model.depthPreview
                    {
                        DepthLegend(visualization: preview.visualization)
                    }
                    if model.activePoint != nil {
                        HStack {
                            Button("←") { model.nudge(dx: -1, dy: 0) }.accessibilityLabel("Geser kiri satu piksel depth")
                            Button("↑") { model.nudge(dx: 0, dy: -1) }.accessibilityLabel("Geser atas satu piksel depth")
                            Button("↓") { model.nudge(dx: 0, dy: 1) }.accessibilityLabel("Geser bawah satu piksel depth")
                            Button("→") { model.nudge(dx: 1, dy: 0) }.accessibilityLabel("Geser kanan satu piksel depth")
                        }.buttonStyle(.bordered).controlSize(.large)
                    }
                    if !model.analysisText.isEmpty {
                        DisclosureGroup("Detail stride dan sensitivitas") { Text(model.analysisText).font(.caption) }
                    }
                    content
                    if model.flow.stage == .inspection {
                        Button {
                            onRetake()
                        } label: {
                            Label("Retake gambar", systemImage: "arrow.counterclockwise")
                        }
                        .buttonStyle(.bordered)
                    }
                    details
                }.padding(20)
            }
        }
        .navigationTitle("Periksa profil sapi")
        .navigationBarTitleDisplayMode(.inline)
        .navigationSubtitle("Estimasi dengan kamera LiDAR")
        .toolbar {
            if model.flow.stage != .inspection {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        model.previous()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .accessibilityLabel("Kembali ke langkah sebelumnya")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Keluar", systemImage: "rectangle.portrait.and.arrow.right") {
                    onExit()
                }
                .tint(.red)
                .accessibilityHint("Kembali ke halaman sebelum kamera")
            }
            if model.flow.stage != .results {
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        advanceStage()
                    } label : {
                        Label("Lanjut", systemImage: "checkmark")
                    }
                    .tint(.blue)
                    .disabled(!canAdvanceStage)
                    .labelStyle(.titleOnly)
                }
            }
            if model.flow.stage == .results {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onFinish()
                    } label: {
                        Label("Finish", systemImage: "checkmark")
                    }
                }
            }
        }
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
            ProgressView(
                value: Double(wizardStep),
                total: Double(wizardStepTotal)
            ).tint(.teal)
            switch model.flow.stage {
            case .inspection:
                Text("Cek foto & depth").font(.title2.bold())
                Text(
                    "Pastikan satu sapi terlihat utuh dari samping. Periksa depth pada area dada."
                )
                .font(.callout).foregroundStyle(.secondary)
            case .point(let index):
                let step = model.steps[index]
                Text(step.title).font(.title2.bold())
                HStack(spacing: 12) {
                    GuideIllustration(step: step)
                    Text(step.instruction).font(.callout)
                }
            case .results:
                Text("Hasil pengukuran").font(.title2.bold())
                Text(
                    "Periksa titik dan kelayakan depth sebelum memakai estimasi ini."
                )
                .font(.callout).foregroundStyle(.secondary)
            }
        }
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
        Picker("Tampilan", selection: $model.display) {
            ForEach(CaptureDisplay.allCases) { display in
                Text(display.rawValue).tag(display)
            }
        }
        .pickerStyle(.segmented)
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
                    "Profil dada membaca piksel raw depth sepanjang garis. Celah dan lonjakan depth memutus segmen. Lingkar dada dan bobot belum dihitung."
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
                Text("\(profile.samples.filter { $0.point != nil }.count)/\(profile.samples.count) piksel terbaca · \(profile.segmentLengthsCM.count) segmen")
                Text("Hijau: tersambung · merah: piksel ditolak · jingga: awal segmen/putus. Garis kuning hanya panduan penandaan.")
                    .font(.caption)
                Text("Raw depth · confidence ≥1 · 0,25–5 m · putus jika lonjakan ≥8 cm. Panjang ini belum merupakan lingkar dada.")
                    .font(.caption)
                ForEach(Array(profile.segmentLengthsCM.enumerated()), id: \.offset) { index, length in
                    Text("Segmen \(index + 1): \(length.formatted(.number.precision(.fractionLength(1)))) cm")
                }
                DisclosureGroup("Piksel dan celah profil") {
                    ForEach(Array(profile.samples.enumerated()), id: \.offset) { _, sample in
                        VStack(alignment: .leading) {
                            Text("(\(sample.x), \(sample.y)) · z \(sample.depth) m · confidence \(sample.confidence)")
                            Text("\(sample.connectedToPrevious ? "Terhubung" : "Awal/putus") · \(sample.status)")
                            if let p = sample.point {
                                Text("XYZ: \(p.x), \(p.y), \(p.z) m")
                            }
                        }.font(.caption).frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            if let girth = result.girth {
                LabeledContent(
                    "Lingkar dada",
                    value:
                        "\(girth.centimeters.formatted(.number.precision(.fractionLength(1)))) cm"
                )
                Text(
                    "\(girth.validSamples) sampel · residu \(girth.residualMeters.formatted(.number.precision(.fractionLength(3)))) m"
                )
                .font(.caption).foregroundStyle(.secondary)
            }
            if let weight = result.weightKG {
                LabeledContent(
                    "Bobot Winter",
                    value:
                        "≈ \(weight.formatted(.number.precision(.fractionLength(0)))) kg"
                )
            }
        }.padding().frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview("Cek capture") {
    NavigationStack {
        MeasurementView(
            viewModel: .preview(.inspection),
            onExit: {},
            onFinish: {},
            onRetake: {}
        )
    }
}

#Preview("Titik ukur") {
    NavigationStack {
        MeasurementView(
            viewModel: .preview(.point(1)),
            onExit: {},
            onFinish: {},
            onRetake: {}
        )
    }
}

#Preview("Hasil") {
    NavigationStack {
        MeasurementView(
            viewModel: .preview(.results),
            onExit: {},
            onFinish: {},
            onRetake: {}
        )
    }
}
