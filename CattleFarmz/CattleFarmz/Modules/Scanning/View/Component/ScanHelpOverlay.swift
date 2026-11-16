import SwiftUI

/// Owns help visibility while the caller places instructions within its preview.
struct ScanHelpOverlay<Content: View>: View {
    @State private var isVisible: Bool
    private let content: (Bool) -> Content

    init(
        initiallyVisible: Bool,
        @ViewBuilder content: @escaping (Bool) -> Content
    ) {
        _isVisible = State(initialValue: initiallyVisible)
        self.content = content
    }

    var body: some View {
        content(isVisible)
            .overlay(alignment: .bottomLeading) {
                ScanIconButton(
                    systemImage: "questionmark.circle",
                    accessibilityLabel: "Petunjuk pemindaian",
                    style: isVisible ? .primary : .material
                ) {
                    isVisible.toggle()
                }
                .accessibilityValue(isVisible ? "Ditampilkan" : "Disembunyikan")
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xxl)
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
    let initiallyVisible: Bool

    var body: some View {
        ScanHelpOverlay(initiallyVisible: initiallyVisible) { isHelpVisible in
            ScanViewport { _ in
                LinearGradient(colors: [.gray, .black], startPoint: .top, endPoint: .bottom)
                    .overlay(alignment: .bottom) {
                        if isHelpVisible {
                            ScanInstructionCard {
                                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                                    Text("Foto sapi dari samping")
                                        .font(AppFont.mediumBody)
                                    Text("Tekan tombol tanda tanya untuk menyembunyikan petunjuk.")
                                        .font(AppFont.caption)
                                }
                            }
                            .frame(maxWidth: 340)
                            .padding(AppSpacing.lg)
                        }
                    }
            }
            .background(AppColor.Surface.canvas)
        }
    }
}
