import SwiftUI

@MainActor
struct MeasurementView: View {
    @Bindable var model: MeasurementViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    introduction
                    displayPicker
                    PhotoCanvas(image: model.capture.image, depthImage: model.depthPreview?.image,
                                crop: model.capture.metadata.previewCrop, display: model.display,
                                landmarks: visibleLandmarks, activeID: model.flow.currentID,
                                enabled: model.flow.currentID != nil, onMove: model.moveActivePoint)
                        .frame(height: min(490, max(300, geometry.size.height * 0.52)))
                    if model.depthLoading { ProgressView("Menyiapkan tampilan depth…") }
                    if model.display != .photo, let preview = model.depthPreview {
                        DepthLegend(visualization: preview.visualization)
                    }
                    content
                    details
                }.padding(20)
            }
        }
        .navigationTitle("Ukur sapi")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Tutup") { dismiss() } } }
        .safeAreaInset(edge: .bottom) { footer }
        .task { model.prepare() }
    }

    @ViewBuilder private var introduction: some View {
        switch model.flow.stage {
        case .inspection:
            Text("1 / 3 · CEK CAPTURE").font(.caption.bold()).foregroundStyle(.teal)
            Text("Cek foto & depth").font(.title2.bold())
            Text("Pastikan satu sapi terlihat utuh dari samping. Periksa depth pada area dada.")
                .font(.callout).foregroundStyle(.secondary)
        case .point(let index):
            let step = model.steps[index]
            Text("2 / 3 · TITIK \(index + 1) DARI \(model.steps.count)")
                .font(.caption.bold()).foregroundStyle(.teal)
            ProgressView(value: Double(index + 1), total: Double(model.steps.count)).tint(.teal)
            Text(step.title).font(.title2.bold())
            HStack(spacing: 12) {
                GuideIllustration(step: step)
                Text(step.instruction).font(.callout)
            }
        case .results:
            Text("3 / 3 · HASIL").font(.caption.bold()).foregroundStyle(.teal)
            Text("Hasil pengukuran").font(.title2.bold())
            Text("Periksa titik dan kelayakan depth sebelum memakai estimasi ini.")
                .font(.callout).foregroundStyle(.secondary)
        }
    }

    private var displayPicker: some View {
        HStack(spacing: 4) {
            ForEach(CaptureDisplay.allCases) { display in
                Button { model.display = display } label: {
                    Text(display.rawValue).font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(model.display == display ? Color.teal : Color.clear,
                                    in: RoundedRectangle(cornerRadius: 9))
                        .foregroundStyle(model.display == display ? Color.white : Color.primary)
                }
                .buttonStyle(.plain)
                .disabled(display != .photo && model.depthPreview == nil)
            }
        }.padding(4).background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
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
                Label(error, systemImage: "exclamationmark.triangle").foregroundStyle(.orange)
            } else if !model.depthLoading && !model.canBegin {
                Text("Depth belum cukup terbaca. Ambil ulang dari posisi yang lebih jelas.")
                    .foregroundStyle(.orange)
            } else {
                Text("Area abu-abu berarti depth visual kurang terbaca. Periksa area tubuh dan titik ukur.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        case .point:
            if let step = model.currentStep, model.activePoint != nil {
                if let problem = model.currentDepthProblem {
                    Label(problem, systemImage: "exclamationmark.circle").foregroundStyle(.orange)
                } else {
                    Label("Titik \(step.number) dapat digunakan", systemImage: "mappin.circle")
                        .foregroundStyle(.teal)
                }
                Text("Geser titik atau ketuk posisi baru jika belum tepat.")
                    .font(.footnote).foregroundStyle(.secondary)
                Button("Hapus titik ini") { model.clearCurrentPoint() }
            } else if let step = model.currentStep {
                Label("Ketuk foto untuk menaruh titik \(step.number).", systemImage: "hand.tap")
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
                    Button("Perbaiki titik dada") { model.editPoints(from: 2) }.buttonStyle(.bordered)
                }
            } else {
                Label(model.message ?? "Ukuran belum dapat dihitung. Periksa titik atau ambil ulang.",
                      systemImage: "exclamationmark.triangle").foregroundStyle(.orange)
            }
            Button("Koreksi titik dari awal") { model.editPoints() }.buttonStyle(.bordered)
        }
    }

    private var details: some View {
        DisclosureGroup("Detail pengukuran") {
            VStack(alignment: .leading, spacing: 8) {
                if let preview = model.depthPreview {
                    let rawFraction=Double(model.rawValidCount)/Double(max(1,model.capture.metadata.depth.meters.count))
                    Text("Depth visual valid pada \(Int(preview.visualization.validFraction * 100))% frame. Depth mentah untuk hitungan valid pada \(Int(rawFraction * 100))% frame.")
                    Text(model.usesSmoothedDepth
                         ? "Depth warna dihaluskan ARKit untuk pemeriksaan visual. Titik ukur dan hitungan memakai depth mentah dari frame yang sama."
                         : "Depth warna memakai data mentah karena versi halus tidak tersedia. Titik ukur dan hitungan memakai data mentah.")
                }
                if let point = model.activePoint,
                   let xyz = try? model.capture.metadata.depth.point(at: point.point) {
                    Text("Depth titik aktif: \(xyz.z.formatted(.number.precision(.fractionLength(2)))) m")
                }
                Text("Lingkar dada: sampel 3D → MLS lokal → interpolasi RBF → cermin sisi tersembunyi. Simetri merupakan asumsi; belum tervalidasi pada sapi nyata.")
            }.font(.caption).padding(.top, 8)
        }
    }

    private var footer: some View {
        VStack(spacing: 9) {
            switch model.flow.stage {
            case .inspection:
                primary("Lanjut ke titik ukur", enabled: model.canBegin) { model.beginGuide() }
                Button("Ambil ulang") { dismiss() }
            case .point(let index):
                primary(index == model.steps.count - 1 ? "Hitung estimasi" : "Titik sesuai · Lanjut",
                        enabled: model.canAdvance) { model.advance() }
                HStack {
                    Button("Sebelumnya") { model.previous() }
                    Spacer()
                    Button("Ambil ulang") { dismiss() }
                }
            case .results:
                primary("Selesai") { dismiss() }
                Button("Ambil ulang") { dismiss() }
            }
        }
        .font(.subheadline).padding(.horizontal, 20).padding(.vertical, 12)
        .frame(maxWidth: .infinity).background(.regularMaterial)
    }

    private func primary(_ title: String, enabled: Bool = true, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.headline).frame(maxWidth: .infinity).padding(.vertical, 8)
        }.buttonStyle(.borderedProminent).disabled(!enabled)
    }

    private func resultCard(_ result: MeasurementResult) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Estimasi eksperimental · belum tervalidasi")
                .font(.caption).foregroundStyle(.orange)
            LabeledContent("Panjang badan", value: "\(result.lengthCM.formatted(.number.precision(.fractionLength(1)))) cm")
            if let girth = result.girth {
                LabeledContent("Lingkar dada", value: "\(girth.centimeters.formatted(.number.precision(.fractionLength(1)))) cm")
                Text("\(girth.validSamples) sampel · residu \(girth.residualMeters.formatted(.number.precision(.fractionLength(3)))) m")
                    .font(.caption).foregroundStyle(.secondary)
            }
            if let weight = result.weightKG {
                LabeledContent("Bobot Winter", value: "≈ \(weight.formatted(.number.precision(.fractionLength(0)))) kg")
            }
        }.padding().frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 16))
    }
}
