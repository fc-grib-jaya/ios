import SwiftUI

/// An example illustration, not an automatically detected location on the photo.
struct MeasurementPointGuide: View {
    let page: ScanGuidePage

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            AnimatedGuideGIF(resourceName: page.imageName)
                .blendMode(.screen)

            Text(page.title)
                .font(AppFont.mediumBody)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black, radius: 3)
        }
        .allowsHitTesting(false)
    }
}

#Preview("Point GIF guide", traits: .fixedLayout(width: 370, height: 370)) {
    MeasurementPointGuide(page: ScanGuidePage.pages[1])
        .padding(AppSpacing.lg)
        .background(.gray)
}
