import SwiftUI

/// Decorative camera guide. Adjust its stroke and corner length here.
struct ScanGuideFrame: View {
    private let lineWidth: CGFloat = 5
    private let cornerLength: CGFloat = 40
    private let cornerRadius: CGFloat = 20

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = max(0, geometry.size.width - lineWidth)
                let height = max(0, geometry.size.height - lineWidth)
                let length = min(cornerLength, min(width, height) / 2)
                let radius = min(cornerRadius, length)
                // Cubic approximation of a rounded quarter-circle.
                let control = radius * (1 - 0.5522847498)

                var corner = Path()
                corner.move(to: CGPoint(x: length, y: 0))
                corner.addLine(to: CGPoint(x: radius, y: 0))
                corner.addCurve(
                    to: CGPoint(x: 0, y: radius),
                    control1: CGPoint(x: control, y: 0),
                    control2: CGPoint(x: 0, y: control)
                )
                corner.addLine(to: CGPoint(x: 0, y: length))

                for (x, y): (CGFloat, CGFloat) in [(1, 1), (-1, 1), (1, -1), (-1, -1)] {
                    path.addPath(corner, transform: CGAffineTransform(
                        a: x, b: 0, c: 0, d: y,
                        tx: lineWidth / 2 + (x < 0 ? width : 0),
                        ty: lineWidth / 2 + (y < 0 ? height : 0)
                    ))
                }
            }
            .stroke(.white, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview("Corner guide", traits: .fixedLayout(width: 600, height: 400)) {
    ScanGuideFrame()
        .frame(width: 533, height: 348)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
}
