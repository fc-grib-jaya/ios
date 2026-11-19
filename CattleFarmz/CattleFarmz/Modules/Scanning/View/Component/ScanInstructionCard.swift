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
    .frame(width: 370)
    .padding(AppSpacing.lg)
    .background(AppColor.Surface.canvas)
}

#Preview("Camera instructions2", traits: .sizeThatFitsLayout) {
    let bagian = "Punuk"
    ScanInstructionCard {
        VStack(spacing: AppSpacing.md){
            VStack(spacing: 10){
                Image("Punuk")
                
                Text("Tandai Bagian \(bagian)")
                    .font(AppFont.headline)
                
                Text("Cari garis tepat di belakang kaki ketuk tepi atas punuk")
            }
            
            Button {

            } label: {
                Text("Lanjutkan Estimasi")
                    .padding(.vertical, AppSpacing.sm)
                    .padding(.horizontal, AppSpacing.huge)
                    .foregroundStyle(AppColor.Primitive.Primary.shade500)
                    .background(AppColor.Primitive.Primary.shade50)
                    .contentShape(Capsule())
            }
        }
        .frame(maxWidth: 268)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .center)
    }
    .frame(width: 370)
    .padding(AppSpacing.md)
    .background(.black)
}
