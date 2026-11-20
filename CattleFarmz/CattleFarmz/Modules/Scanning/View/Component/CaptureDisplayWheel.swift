//
//  CaptureDisplayWheel.swift
//  CattleFarmz
//

import SwiftUI

/// Vertical display selector with labels read from bottom to top.
struct CaptureDisplayWheel: View {
    @Binding var selection: CaptureDisplay

    var body: some View {
        VStack(spacing: 8) {
            ForEach([CaptureDisplay.depth, .overlay, .photo]) { option in
                Button {
                    selection = option
                } label: {
                    Text(title(for: option))
                        .font(AppFont.mediumBody)
                        .foregroundStyle(selection == option ? AppColor.Primitive.Primary.shade400 : AppColor.Primitive.Neutral.shade300)
                        .fixedSize()
                        .rotationEffect(.degrees(-90))
                        .frame(width: 18, height: 75)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(title(for: option))
                .accessibilityAddTraits(selection == option ? .isSelected : [])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tampilan capture")
    }

    private func title(for option: CaptureDisplay) -> String {
        switch option {
        case .photo: "Normal"
        case .overlay: "Combine"
        case .depth: "Depth"
        }
    }
}

#Preview("Depth selected") {
    @Previewable @State var selection: CaptureDisplay = .overlay
    ZStack {
        Color.black.ignoresSafeArea()
        CaptureDisplayWheel(selection: $selection)
    }
}
