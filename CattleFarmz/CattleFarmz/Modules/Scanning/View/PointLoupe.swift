import SwiftUI

/// Display magnification only: each sensor pixel retains its original footprint.
struct PointLoupe: View {
    let image: CGImage
    let point: Point2
    let depth: DepthFrame
    var body: some View {
        Canvas { context, size in
            let span = 0.10
            let scale = size.width / span
            let heightScale = scale * Double(image.height) / Double(image.width)
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let rect = CGRect(x: center.x - point.x * scale, y: center.y - point.y * heightScale, width: scale, height: heightScale)
            context.draw(Image(decorative: image, scale: 1), in: rect)
            let raw = depth.orientation.rawPoint(fromDisplay: point)
            let x = min(depth.width - 1, max(0, Int(raw.x * Double(depth.width))))
            let y = min(depth.height - 1, max(0, Int(raw.y * Double(depth.height))))
            let a = depth.orientation.displayPoint(fromRaw: Point2(Double(x) / Double(depth.width), Double(y) / Double(depth.height)))
            let b = depth.orientation.displayPoint(fromRaw: Point2(Double(x + 1) / Double(depth.width), Double(y + 1) / Double(depth.height)))
            let box = CGRect(x: center.x + (min(a.x,b.x) - point.x) * scale, y: center.y + (min(a.y,b.y) - point.y) * heightScale, width: abs(a.x-b.x) * scale, height: abs(a.y-b.y) * heightScale)
            context.stroke(Path(box), with: .color(.yellow), lineWidth: 1)
            var cross = Path()
            cross.move(to: CGPoint(x: center.x - 6, y: center.y)); cross.addLine(to: CGPoint(x: center.x + 6, y: center.y))
            cross.move(to: CGPoint(x: center.x, y: center.y - 6)); cross.addLine(to: CGPoint(x: center.x, y: center.y + 6))
            context.stroke(cross, with: .color(.mint), lineWidth: 1)
        }.background(.black).clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(alignment: .bottom) { Text("+ anatomi · □ depth").font(.caption2).padding(3).background(.black.opacity(0.7)) }
            .accessibilityLabel("Pembesar titik anatomi dan footprint piksel depth")
    }
}
