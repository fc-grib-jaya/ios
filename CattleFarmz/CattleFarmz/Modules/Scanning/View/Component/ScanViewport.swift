import SwiftUI

/// Keeps the live camera and captured photo at the same landscape dimensions.
struct ScanViewport<Content: View>: View {
    @ViewBuilder var content: (CGSize) -> Content

    var body: some View {
        GeometryReader { geometry in
            let size = CGSize(width: geometry.size.width, height: geometry.size.height)

            content(size)
                .frame(width: size.width, height: size.height)
//                .clipShape(RoundedRectangle(cornerRadius: 40))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
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
