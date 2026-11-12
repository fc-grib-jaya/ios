import CoreGraphics
import SwiftUI

@MainActor struct PhotoCanvas: View {
    let image: CGImage
    let depthImage: CGImage?
    let crop: ImageCrop
    let display: CaptureDisplay
    let landmarks: [Landmark]
    let activeID: String?
    let enabled: Bool
    let onMove: (Point2) -> Void
    var profile: ChestDepthProfile? = nil
    var depthFrame: DepthFrame? = nil
    var onPlacementEnded: () -> Void = {}
    @State private var dragOffset: Point2?

    var body: some View {
        GeometryReader { geometry in
            let imageSize = CGSize(width: Double(image.width) * crop.width, height: Double(image.height) * crop.height)
            let scale = min(
                geometry.size.width / imageSize.width,
                geometry.size.height / imageSize.height
            )
            let size = CGSize(
                width: imageSize.width * scale,
                height: imageSize.height * scale
            )
            let origin = CGPoint(
                x: (geometry.size.width - size.width) / 2,
                y: (geometry.size.height - size.height) / 2
            )
            ZStack(alignment: .topLeading) {
                Color.black
                ZStack(alignment: .topLeading) {
                    Image(decorative: image, scale: 1).resizable()
                        .frame(width: size.width / crop.width, height: size.height / crop.height)
                        .offset(x: -crop.x * size.width / crop.width, y: -crop.y * size.height / crop.height)
                    if let depthImage, display != .photo {
                        Image(decorative: depthImage, scale: 1).resizable().interpolation(.none)
                            .frame(width: size.width / crop.width, height: size.height / crop.height)
                            .offset(x: -crop.x * size.width / crop.width, y: -crop.y * size.height / crop.height)
                            .opacity(display == .depth ? 1 : 0.55)
                    }
                }.frame(width: size.width, height: size.height, alignment: .topLeading).clipped()
                    .offset(x: origin.x, y: origin.y)
                if let a = landmarks.first(where: { $0.id == "shoulder" }),
                    let b = landmarks.first(where: { $0.id == "pin" })
                {
                    Path { path in
                        path.move(
                            to: screenPoint(a.point, origin: origin, size: size)
                        )
                        path.addLine(
                            to: screenPoint(b.point, origin: origin, size: size)
                        )
                    }.stroke(
                        AppColor.Primitive.Primary.shade500,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                }
                if let top = landmarks.first(where: { $0.id == "chestTop" }),
                    let bottom = landmarks.first(where: {
                        $0.id == "chestBottom"
                    })
                {
                    Path { path in
                        path.move(
                            to: screenPoint(
                                top.point,
                                origin: origin,
                                size: size
                            )
                        )
                        path.addLine(
                            to: screenPoint(
                                bottom.point,
                                origin: origin,
                                size: size
                            )
                        )
                    }.stroke(
                        AppColor.Primitive.Primary.shade500,
                        style: StrokeStyle(lineWidth: 2, dash: [5, 3])
                    )
                }
                if let profile {
                    Canvas { context, _ in
                        for (index, sample) in profile.samples.enumerated() {
                            let position = screenPoint(sample.displayPoint, origin: origin, size: size)
                            if sample.connectedToPrevious, index > 0 {
                                var path = Path()
                                path.move(to: screenPoint(profile.samples[index - 1].displayPoint, origin: origin, size: size))
                                path.addLine(to: position)
                                context.stroke(path, with: .color(.green), lineWidth: 4)
                            }
                            if !sample.connectedToPrevious {
                                let dot = Path(ellipseIn: CGRect(x: position.x - 3, y: position.y - 3, width: 6, height: 6))
                                context.fill(dot, with: .color(sample.point == nil ? .red : .orange))
                            }
                        }
                    }.allowsHitTesting(false)
                }
                ForEach(landmarks) { point in
                    let active = point.id == activeID
                    let stepNumber = MeasurementGuideStep.steps.first { $0.id == point.id }?.number
                    ZStack {
                        Circle()
                            .fill(AppColor.Primitive.Primary.shade500)
                        if active {
                            Circle()
                                .strokeBorder(.white, lineWidth: 2)
                                .frame(width: 26, height: 26)
                        }
                        if let stepNumber {
                            Text(stepNumber.formatted())
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(width: 32, height: 32)
                    .position(
                        screenPoint(point.point, origin: origin, size: size)
                    )
                }
            }
            .overlay(alignment: (landmarks.first(where: { $0.id == activeID })?.point.x ?? 0) < crop.x + crop.width / 2 ? .topTrailing : .topLeading) {
                if let active = landmarks.first(where: { $0.id == activeID }), let depthFrame {
                    PointLoupe(image: image, point: active.point, depth: depthFrame)
                        .frame(width: min(160, geometry.size.width / 3), height: 160)
                        .padding(8).allowsHitTesting(false)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0).onChanged { value in
                    guard enabled, activeID != nil,
                        CGRect(origin: origin, size: size).contains(
                            value.startLocation
                        )
                    else { return }
                    let start = normalized(
                        value.startLocation,
                        origin: origin,
                        size: size
                    )
                    let end = normalized(
                        value.location,
                        origin: origin,
                        size: size
                    )
                    if dragOffset == nil {
                        if let current = landmarks.first(where: {
                            $0.id == activeID
                        }),
                            hypot(
                                (current.point.x - start.x) * size.width
                                    / crop.width,
                                (current.point.y - start.y) * size.height
                                    / crop.height
                            ) < 30
                        {
                            dragOffset = Point2(
                                current.point.x - start.x,
                                current.point.y - start.y
                            )
                        } else {
                            dragOffset = Point2(0, 0)
                        }
                    }
                    let offset = dragOffset ?? Point2(0, 0)
                    onMove(
                        Point2(
                            min(
                                crop.x + crop.width,
                                max(crop.x, end.x + offset.x)
                            ),
                            min(
                                crop.y + crop.height,
                                max(crop.y, end.y + offset.y)
                            )
                        )
                    )
                }.onEnded { _ in dragOffset = nil; onPlacementEnded() }
            )
            .onChange(of: activeID) { _, _ in dragOffset = nil }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                enabled
                    ? "Foto pengukuran. Ketuk atau geser untuk menempatkan titik aktif."
                    : "Tampilan \(display.rawValue) dari capture."
            )
        }
//        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func screenPoint(_ point: Point2, origin: CGPoint, size: CGSize)
        -> CGPoint
    {
        CGPoint(
            x: origin.x + (point.x - crop.x) / crop.width * size.width,
            y: origin.y + (point.y - crop.y) / crop.height * size.height
        )
    }
    private func normalized(_ point: CGPoint, origin: CGPoint, size: CGSize)
        -> Point2
    {
        Point2(
            crop.x + (point.x - origin.x) / size.width * crop.width,
            crop.y + (point.y - origin.y) / size.height * crop.height
        )
    }
}
