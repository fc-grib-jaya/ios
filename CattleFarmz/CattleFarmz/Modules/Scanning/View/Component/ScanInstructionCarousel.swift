import SwiftUI

/// Browsing instructions never selects or confirms a measurement point.
struct ScanInstructionCarousel: View {
    let onContinue: () -> Void
    @State private var pageIndex = 0
    private let pages = ScanGuidePage.pages
    
    var body: some View {
        let page = pages[pageIndex]
        
        ScanInstructionCard {
            HStack(spacing: AppSpacing.md){
                Button {
                    pageIndex = max(0, pageIndex - 1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(AppFont.title)
                }
                .disabled(pageIndex == 0)
                .opacity(pageIndex == 0 ? 0 : 1)
                .accessibilityHidden(pageIndex == 0)
                .foregroundStyle(AppColor.Primitive.Primary.shade500)
                
                VStack(spacing: AppSpacing.md) {
                        VStack(spacing: 10) {
                            Image(page.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 88)
                                .accessibilityHidden(true)
                            
                            Text(page.title)
                                .font(AppFont.headline)
                            
                            Text(page.instruction)
                                .font(AppFont.body)
                        }
                        .frame(maxWidth: 270)
                        .frame(maxWidth: .infinity)
                    
                    Button(action: onContinue) {
                        Text("Lanjutkan Estimasi")
                            .font(AppFont.mediumBody)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .foregroundStyle(AppColor.Primitive.Primary.shade500)
                            .background(AppColor.Primitive.Primary.shade50, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                
                Button {
                    pageIndex = min(pages.count - 1, pageIndex + 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(AppFont.title)
                }
                .disabled(pageIndex == pages.count - 1)
                .opacity(pageIndex == pages.count - 1 ? 0 : 1)
                .accessibilityHidden(pageIndex == pages.count - 1)
                .foregroundStyle(AppColor.Primitive.Primary.shade500)
            }
        }
    }
}

#Preview("Camera guide pages", traits: .fixedLayout(width: 402, height: 402)) {
    ScanInstructionCarousel(onContinue: {})
        .frame(width: 370, height: 370)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
}
