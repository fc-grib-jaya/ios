import SwiftUI

/// Common surface for camera and measurement instructions.
struct ScanInstructionCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 50))
    }
}

#Preview("Camera instructions", traits: .sizeThatFitsLayout) {
    ScanInstructionCard {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "info.circle")
                .font(AppFont.title)
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("Foto sapi dari samping")
                    .font(AppFont.mediumBody)
                Text("Pastikan pengambilan foto simetris")
                    .font(AppFont.mediumSubheadline)
                    .foregroundStyle(AppColor.Text.secondary)
            }
        }
    }
    .frame(width: 340)
    .padding(AppSpacing.lg)
    .background(AppColor.Surface.canvas)
}
