import SwiftUI

/// Displays instructions; each screen owns its visibility and help button layout.
struct ScanHelpOverlay<Content: View>: View {
    var isVisible: Bool
    @ViewBuilder var content: () -> Content

    @ViewBuilder
    var body: some View {
        if isVisible {
            content()
        }
    }
}

#Preview("Help hidden", traits: .fixedLayout(width: 874, height: 402)) {
    ScanHelpOverlayPreview(initiallyVisible: false)
}

#Preview("Help visible", traits: .fixedLayout(width: 874, height: 402)) {
    ScanHelpOverlayPreview(initiallyVisible: true)
}

private struct ScanHelpOverlayPreview: View {
    @State private var isHelpVisible: Bool

    init(initiallyVisible: Bool) {
        _isHelpVisible = State(initialValue: initiallyVisible)
    }

    var body: some View {
        ScanViewport { _ in
            LinearGradient(colors: [.gray, .black], startPoint: .top, endPoint: .bottom)
                .overlay(alignment: .bottom) {
                    ScanHelpOverlay(isVisible: isHelpVisible) {
                        ScanInstructionCard {
                            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                                Text("Foto sapi dari samping")
                                    .font(AppFont.mediumBody)
                                Text("Tekan tombol untuk menyembunyikan petunjuk.")
                                    .font(AppFont.caption)
                            }
                        }
                        .frame(maxWidth: 340)
                        .padding(AppSpacing.lg)
                    }
                }
        }
        .overlay(alignment: .topLeading) {
            Button("Toggle petunjuk") { isHelpVisible.toggle() }
                .buttonStyle(.borderedProminent)
                .padding(AppSpacing.md)
        }
        .background(AppColor.Surface.canvas)
    }
}
