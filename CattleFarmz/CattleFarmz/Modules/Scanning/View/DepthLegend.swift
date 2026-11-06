import SwiftUI

struct DepthLegend: View {
    let visualization: DepthVisualization

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            if let near = visualization.nearMeters, let far = visualization.farMeters {
                Text(visualization.validCount >= 20
                     ? "Jarak dari kamera · skala warna 5–95%"
                     : "Jarak dari kamera")
                    .font(.caption.weight(.semibold))
                if far > near {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(colors: [color(0), color(0.5), color(1)], startPoint: .leading, endPoint: .trailing))
                        .frame(height: 9)
                    HStack {
                        Text("Dekat · \(meters(near)) m")
                        Spacer()
                        Text("Jauh · \(meters(far)) m")
                    }.font(.caption).monospacedDigit()
                } else {
                    HStack(spacing: 8) {
                        Circle().fill(color(0.5)).frame(width: 10, height: 10)
                        Text("Depth seragam · \(meters(near)) m").font(.caption)
                    }
                }
            } else {
                Text("Belum ada depth yang cukup terbaca.").font(.caption.weight(.semibold)).foregroundStyle(.orange)
            }
            Label("Abu-abu: depth visual tidak valid atau keyakinannya rendah", systemImage: "square.grid.2x2.fill")
                .font(.caption2).foregroundStyle(.secondary)
        }.accessibilityElement(children: .combine)
    }
    private func color(_ fraction: Double) -> Color {
        let c = DepthVisualization.color(at: fraction)
        return Color(red: Double(c.0) / 255, green: Double(c.1) / 255, blue: Double(c.2) / 255)
    }
    private func meters(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(2)))
    }
}
