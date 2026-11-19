import SwiftUI

enum ScanViewportLayout {
    static func previewSize(in availableSize: CGSize) -> CGSize {
        CGSize(width: availableSize.width * 672 / 874, height: availableSize.height)
    }
}

/// Applies the shared landscape viewport proportions to camera and photo content.
struct ScanViewport<Content: View>: View {
    var previewSize: CGSize? = nil
    @ViewBuilder var content: (CGSize) -> Content

    @ViewBuilder
    var body: some View {
        if let previewSize {
            viewport(size: previewSize)
        } else {
            GeometryReader { geometry in
                viewport(size: ScanViewportLayout.previewSize(in: geometry.size))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func viewport(size: CGSize) -> some View {
        content(size)
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: 40))
    }
}

#Preview("Landscape viewport", traits: .fixedLayout(width: 874, height: 402)) {
    ScanViewport { size in
        LinearGradient(colors: [.gray, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "camera.viewfinder")
                        .font(.largeTitle)
                    Text("\(Int(size.width)) × \(Int(size.height)) pt")
                        .font(.headline.monospacedDigit())
                }
                .foregroundStyle(.white)
            }
    }
    .background(AppColor.Surface.canvas)
}
