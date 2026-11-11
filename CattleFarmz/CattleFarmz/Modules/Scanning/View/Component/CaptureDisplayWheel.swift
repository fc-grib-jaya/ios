//
//  CaptureDisplayWheel.swift
//  CattleFarmz
//
//  Created by Salman on 11/11/26.
//

import SwiftUI

struct CaptureDisplayWheel: View {
    @Binding var selection: CaptureDisplay
    @GestureState private var dragOffset: CGFloat = 0

    private let options = Array(CaptureDisplay.allCases)
    private let itemSpacing: CGFloat = 80

    private var selectedIndex: Int {
        options.firstIndex(of: selection) ?? 0
    }

    var body: some View {
        ZStack {
            ForEach(options) { option in
                optionButton(option)
            }

            // Cincin selalu berada di tengah.
            Circle()
                .strokeBorder(.white, lineWidth: 3)
                .frame(width: 76, height: 76)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .frame(width: 88, height: 240)
        .contentShape(Rectangle())
        .clipped()
        .highPriorityGesture(dragGesture)
        .animation(
            .easeOut(duration: 0.2),
            value: selection
        )
    }

    private func optionButton(
        _ option: CaptureDisplay
    ) -> some View {
        let index = options.firstIndex(of: option) ?? 0

        let offset =
            CGFloat(index - selectedIndex) * itemSpacing
            + limitedDragOffset

        // 1 di tengah, 0 ketika berjarak satu slot atau lebih.
        let emphasis = max(
            0,
            1 - abs(offset) / itemSpacing
        )

        let diameter = 48 + 16 * emphasis
        let iconSize = 22 + 6 * emphasis

        return Button {
            selection = option
        } label: {
            Image(systemName: option.icon)
                .font(.system(
                    size: iconSize,
                    weight: .medium
                ))
                .foregroundStyle(.white)
                .frame(
                    width: diameter,
                    height: diameter
                )
                .background {
                    Circle()
                        .fill(.gray.opacity(0.55))
                }
                // Area sentuh tetap, walaupun lingkaran mengecil.
                .frame(width: 76, height: 76)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .offset(y: offset)
        .accessibilityLabel(option.rawValue)
        .accessibilityValue(
            selection == option ? "Dipilih" : "Tidak dipilih"
        )
        .accessibilityHidden(abs(offset) > itemSpacing)
    }

    private var limitedDragOffset: CGFloat {
        // Batasi gerakan agar tidak melewati pilihan pertama/terakhir.
        let minimum =
            -CGFloat(options.count - 1 - selectedIndex) * itemSpacing

        let maximum =
            CGFloat(selectedIndex) * itemSpacing

        return min(max(dragOffset, minimum), maximum)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .updating($dragOffset) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                let movement = value.predictedEndTranslation.height
                var nextIndex = selectedIndex

                // Geser ke atas: pilihan berikutnya naik ke tengah.
                if movement < -itemSpacing / 2 {
                    nextIndex += 1
                } else if movement > itemSpacing / 2 {
                    nextIndex -= 1
                }

                nextIndex = min(
                    max(nextIndex, 0),
                    options.count - 1
                )

                selection = options[nextIndex]
            }
    }
}
