import SwiftUI

/// A schematic guide, never used as a source of measurement coordinates.
struct GuideIllustration: View {
    let step: MeasurementGuideStep

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Canvas { context, size in
                func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
                    CGPoint(x: x * size.width, y: y * size.height)
                }
                var body = Path()
                body.move(to: point(0.27, 0.34))
                body.addCurve(to: point(0.77, 0.31), control1: point(0.43, 0.22), control2: point(0.66, 0.22))
                body.addLine(to: point(0.80, 0.62))
                body.addCurve(to: point(0.36, 0.65), control1: point(0.70, 0.68), control2: point(0.48, 0.68))
                body.addLine(to: point(0.27, 0.34))
                context.fill(body, with: .color(.teal.opacity(0.25)))
                context.stroke(body, with: .color(.teal), lineWidth: 2)
                var head = Path()
                head.move(to: point(0.28, 0.36))
                head.addLine(to: point(0.12, 0.37))
                head.addLine(to: point(0.08, 0.54))
                head.addLine(to: point(0.27, 0.55))
                context.stroke(head, with: .color(.teal), lineWidth: 2)
                for x in [0.33, 0.43, 0.72, 0.78] {
                    var leg = Path()
                    leg.move(to: point(x, 0.62))
                    leg.addLine(to: point(x, 0.90))
                    context.stroke(leg, with: .color(.teal), lineWidth: 3)
                }
                if step.number >= 3 {
                    var section = Path()
                    section.move(to: point(0.44, 0.28))
                    section.addLine(to: point(0.44, 0.65))
                    context.stroke(section, with: .color(.orange), style: StrokeStyle(lineWidth: 2, dash: [3, 3]))
                }
                let positions: [CGPoint] = [
                    point(0.31, 0.51), point(0.79, 0.43),
                    point(0.44, 0.28), point(0.44, 0.65)
                ]
                let marker = positions[step.number - 1]
                context.fill(Path(ellipseIn: CGRect(x: marker.x - 10, y: marker.y - 10, width: 20, height: 20)),
                             with: .color(.orange))
                context.draw(Text("\(step.number)").font(.caption.bold()).foregroundColor(.black), at: marker)
            }
            .frame(width: 150, height: 100)
            Text("Contoh tampak samping").font(.caption2).foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Contoh lokasi \(step.label)")
    }
}
