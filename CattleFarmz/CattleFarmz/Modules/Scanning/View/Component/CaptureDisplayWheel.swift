//
//  CaptureDisplayWheel.swift
//  CattleFarmz
//

import SwiftUI

/// Native scrolling and snapping with a circular camera-control appearance.
struct CaptureDisplayWheel: View {
    @Binding var selection: CaptureDisplay
    @State private var centeredOption: CaptureDisplay?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let itemHeight: CGFloat = 80
    private let viewportHeight: CGFloat = 240

    init(selection: Binding<CaptureDisplay>) {
        self._selection = selection
        self._centeredOption = State(initialValue: selection.wrappedValue)
    }

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(CaptureDisplay.allCases) { option in
                    Button {
                        select(option)
                    } label: {
                        Image(systemName: option.icon)
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 64, height: 64)
                            .background(.ultraThinMaterial, in: Circle())
                            .environment(\.colorScheme, .dark)
                            // Keep the active circle at 64 pt and the others at 48 pt.
                            // Selection is independent of scroll-content coordinate offsets.
                            .scaleEffect(option == (centeredOption ?? selection) ? 1 : 0.75)
                            .opacity(option == (centeredOption ?? selection) ? 1 : 0.65)
                            .animation(
                                reduceMotion ? nil : .smooth(duration: 0.2),
                                value: centeredOption
                            )
                            .frame(width: 88, height: itemHeight)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .id(option)
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.vertical, (viewportHeight - itemHeight) / 2, for: .scrollContent)
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
        .scrollPosition(id: $centeredOption, anchor: .center)
        .frame(width: 88, height: viewportHeight)
        .overlay {
            Circle()
                .strokeBorder(.white, lineWidth: 2.5)
                .frame(width: 76, height: 76)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        // Change the photo/depth layer once scrolling settles, avoiding work
        // on the measurement canvas for every intermediate scroll position.
        .onScrollPhaseChange { _, phase in
            if phase == .idle, let centeredOption {
                selection = centeredOption
            }
        }
        .onChange(of: selection) { _, option in
            withAnimation(reduceMotion ? nil : .smooth(duration: 0.3)) {
                centeredOption = option
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tampilan capture")
        .accessibilityValue(selection.rawValue)
        .accessibilityAdjustableAction { direction in
            let options = CaptureDisplay.allCases
            guard let index = options.firstIndex(of: selection) else { return }
            switch direction {
            case .increment:
                select(options[min(index + 1, options.count - 1)])
            case .decrement:
                select(options[max(index - 1, 0)])
            @unknown default:
                break
            }
        }
    }

    private func select(_ option: CaptureDisplay) {
        selection = option
        // Also handles tapping the selected option during an unfinished drag.
        withAnimation(reduceMotion ? nil : .smooth(duration: 0.3)) {
            centeredOption = option
        }
    }
}

#Preview {
    @Previewable @State var selection: CaptureDisplay = .photo
    ZStack {
        Color.black.ignoresSafeArea()
        CaptureDisplayWheel(selection: $selection)
    }
}
