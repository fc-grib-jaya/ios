//
//  MeasurementProgressBar.swift
//  CattleFarmz
//
//  Created by Salman on 10/11/26.
//

import SwiftUI

struct MeasurementProgressBar: View {
    let currentStep: Int

    // Urutan proses: bawah → tengah → atas.
    var icons: [String]
    
    var activeColor: Color = .green
    var trackColor: Color = .green.opacity(0.25)

    var body: some View {
        VStack(spacing: 14) {
            // VStack menggambar dari atas,
            // jadi tahap terakhir ditampilkan lebih dahulu.
            ForEach(Array(icons.indices.reversed()), id: \.self) { index in
                stepIcon(at: index)

                if index > 0 {
                    Capsule()
                        .fill(
                            currentStep >= index
                                ? activeColor
                                : trackColor
                        )
                        .frame(width: 7)
                        .frame(maxHeight: .infinity)
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background {
            Capsule()
                .fill(trackColor)
        }
        .frame(maxWidth: 40)
        .animation(
            .easeInOut(duration: 0.25),
            value: currentStep
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tahap pengukuran")
        .accessibilityValue(
            "Tahap \(currentStep + 1) dari \(icons.count)"
        )
    }

    private func stepIcon(at index: Int) -> some View {
        let isReached = index <= currentStep
        let isCurrent = index == currentStep

        return Image(systemName: icons[index])
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(
                isReached ? Color.white : activeColor
            )
            .frame(width: 32, height: 32)
            .background {
                Circle()
                    .fill(
                        isReached ? activeColor : trackColor
                    )
            }
            .overlay {
                if isCurrent {
                    Circle()
                        .strokeBorder(.white, lineWidth: 1.5)
                        .padding(1.5)
                }
            }
    }
}

struct MeasurementProgressDemo: View {
    @State private var currentStep = 0

    var body: some View {
        HStack(spacing: 40) {
            VStack(spacing: 20) {
                Text("Tahap \(currentStep + 1)")

                Button("Sebelumnya") {
                    currentStep -= 1
                }
                .disabled(currentStep == 0)

                Button("Lanjut") {
                    currentStep += 1
                }
                .disabled(currentStep == 2)
            }

            MeasurementProgressBar(
                currentStep: currentStep,
                icons: [
                    "camera.fill",
                    "slider.horizontal.3",
                    "waveform"
                ]
            )
            .frame(height: 340)
        }
        .padding()
    }
}

#Preview {
    MeasurementProgressDemo()
}
