//
//  ToastView.swift
//  CattleFarmz
//

import Foundation
import SwiftUI

/// Visual stages of the toast timeline.
private enum ToastPhase {
    case initial
    case dropping
    case bouncing
    case materialReveal
    case expanding
    case visible
    case dismissing
    case completed
}

/// One animated toast.
///
/// A single task owns the whole timeline: drop, two bounces, material reveal,
/// expansion, content reveal, visible duration, then exit. Manual dismissal
/// cancels the timeline and runs the exit animation once. Every suspension is
/// cancellable, and no state is written after cancellation.
struct ToastView: View {
    let item: ToastItem
    let configuration: ToastConfiguration
    let availableWidth: CGFloat
    let isDismissRequested: Bool
    let onOvershoot: () -> Void
    let onExitComplete: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var phase: ToastPhase = .initial
    @State private var layout: ToastLayout
    @State private var containerWidth: CGFloat
    @State private var containerHeight: CGFloat
    @State private var verticalOffset: CGFloat
    @State private var materialOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var iconScale: CGFloat = 0.6
    @State private var toastOpacity: Double = 1
    @State private var trailOpacity: Double = 0
    @State private var timelineTask: Task<Void, Never>?

    init(
        item: ToastItem,
        configuration: ToastConfiguration,
        availableWidth: CGFloat,
        isDismissRequested: Bool,
        onOvershoot: @escaping () -> Void,
        onExitComplete: @escaping () -> Void
    ) {
        self.item = item
        self.configuration = configuration
        self.availableWidth = availableWidth
        self.isDismissRequested = isDismissRequested
        self.onOvershoot = onOvershoot
        self.onExitComplete = onExitComplete

        // The environment is unavailable in `init`; `.onAppear` recomputes the
        // layout with the real Dynamic Type size and measured width.
        let layout = ToastLayout.make(
            message: item.message,
            configuration: configuration,
            availableWidth: availableWidth,
            dynamicTypeSize: .large
        )
        _layout = State(initialValue: layout)
        _containerWidth = State(initialValue: layout.initialWidth)
        _containerHeight = State(initialValue: layout.initialHeight)
        _verticalOffset = State(initialValue: -configuration.dropDistance)
    }

    var body: some View {
        ToastContent(
            item: item,
            configuration: configuration,
            textWidth: layout.textWidth,
            contentOpacity: contentOpacity,
            iconScale: iconScale
        )
        .padding(.horizontal, configuration.contentPadding)
        .frame(width: containerWidth, height: containerHeight, alignment: .leading)
        .background {
            Capsule(style: .continuous)
                .fill(configuration.material)
                .opacity(materialOpacity)
        }
        .clipShape(Capsule(style: .continuous))
        .background(alignment: .topLeading) {
            ToastDropTrail(
                color: item.accentColor,
                width: configuration.circleSize,
                height: configuration.trailLength,
                blurRadius: configuration.trailBlurRadius
            )
            .opacity(trailOpacity)
            .offset(
                x: configuration.contentPadding,
                y: containerHeight / 2 - configuration.trailLength
            )
        }
        .opacity(toastOpacity)
        .offset(y: verticalOffset)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.message)
        .onAppear(perform: start)
        .onDisappear {
            // The toast left the hierarchy without finishing its exit (for
            // example the overlay was removed). Cancelling the timeline and
            // reporting completion keeps the queue from blocking forever.
            timelineTask?.cancel()
            onExitComplete()
        }
        .onChange(of: isDismissRequested) { _, requested in
            guard requested else { return }
            requestExit()
        }
        .onChange(of: availableWidth) { _, _ in updateLayout() }
        .onChange(of: dynamicTypeSize) { _, _ in updateLayout() }
    }

    // MARK: - Lifecycle

    private func start() {
        updateLayout()

        if reduceMotion {
            // No drop, bounce, or expansion: show the finished capsule and fade it in.
            verticalOffset = 0
            containerWidth = layout.targetWidth
            containerHeight = layout.targetHeight
        }
        if isDismissRequested {
            timelineTask = Task { await runExit() }
        } else {
            timelineTask = Task { await runTimeline() }
        }
    }

    private func updateLayout() {
        let updated = ToastLayout.make(
            message: item.message,
            configuration: configuration,
            availableWidth: availableWidth,
            dynamicTypeSize: dynamicTypeSize
        )
        guard updated != layout else { return }
        layout = updated

        guard phase == .visible else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            containerWidth = updated.targetWidth
            containerHeight = updated.targetHeight
        }
    }

    /// Starts the exit animation once, cancelling an in-flight entrance.
    private func requestExit() {
        guard phase != .dismissing, phase != .completed else { return }
        timelineTask?.cancel()
        timelineTask = Task { await runExit() }
    }

    // MARK: - Timeline

    private func runTimeline() async {
        guard phase == .initial else { return }

        if reduceMotion {
            await runReducedTimeline()
            return
        }

        phase = .dropping
        // The drop passes the resting position and lands below it, with a green
        // motion trail that fades out right before the first landing.
        withAnimation(.easeOut(duration: 0.1)) {
            trailOpacity = 1
        }
        withAnimation(.easeIn(duration: configuration.dropDuration)) {
            verticalOffset = configuration.overshootBelow
        }
        let trailFadeStart = configuration.dropDuration * 0.7
        guard await pause(trailFadeStart) else { return }
        withAnimation(.easeOut(duration: configuration.dropDuration - trailFadeStart)) {
            trailOpacity = 0
        }
        guard await pause(configuration.dropDuration - trailFadeStart) else { return }
        // First overshoot: the circle has landed below its resting position.
        onOvershoot()

        phase = .bouncing
        // Back up past the destination, then settle onto it: a damped
        // overshoot instead of bouncing above the resting position.
        withAnimation(.easeOut(duration: configuration.bounceDuration)) {
            verticalOffset = -configuration.overshootAbove
        }
        guard await pause(configuration.bounceDuration) else { return }
        // Second overshoot: the circle has reached its highest point again.
        onOvershoot()

        withAnimation(.easeIn(duration: configuration.bounceDuration)) {
            verticalOffset = 0
        }
        guard await pause(configuration.bounceDuration) else { return }

        phase = .materialReveal
        withAnimation(.easeIn(duration: configuration.materialDuration)) {
            materialOpacity = 1
        }
        guard await pause(configuration.materialDuration) else { return }

        phase = .expanding
        withAnimation(
            .spring(
                response: configuration.expandDuration * 0.75,
                dampingFraction: 0.82
            )
        ) {
            containerWidth = layout.targetWidth
            containerHeight = layout.targetHeight
        }

        // Content reveal overlaps the second half of the expansion.
        guard await pause(configuration.expandDuration / 2) else { return }
        withAnimation(.easeOut(duration: configuration.contentRevealDuration)) {
            contentOpacity = 1
            iconScale = 1
        }
        guard await pause(configuration.contentRevealDuration) else { return }

        phase = .visible
        guard await pause(item.duration) else { return }
        await runExit()
    }

    private func runReducedTimeline() async {
        phase = .expanding
        withAnimation(.easeOut(duration: configuration.materialDuration)) {
            materialOpacity = 1
            contentOpacity = 1
            iconScale = 1
        }
        guard await pause(configuration.materialDuration) else { return }

        phase = .visible
        guard await pause(item.duration) else { return }
        await runExit()
    }

    private func runExit() async {
        guard phase != .dismissing, phase != .completed else { return }
        phase = .dismissing

        withAnimation(.easeIn(duration: configuration.dismissDuration)) {
            toastOpacity = 0
            verticalOffset = -configuration.dismissTravel
        }
        guard await pause(configuration.dismissDuration) else { return }

        phase = .completed
        onExitComplete()
    }

    // MARK: - Timing

    /// Suspends for `duration`; returns `false` when the task was cancelled.
    private func pause(_ duration: Duration) async -> Bool {
        do {
            try await Task.sleep(for: duration)
            return !Task.isCancelled
        } catch {
            return false
        }
    }

    private func pause(_ seconds: TimeInterval) async -> Bool {
        await pause(.seconds(seconds))
    }
}

/// Green motion blur trailing the circle while it drops.
///
/// Drawn behind the circle, unclipped by the capsule, and only shown for the
/// first fall: the gradient mask fades the streak toward the top so it reads as
/// speed rather than a second shape.
private struct ToastDropTrail: View {
    let color: Color
    let width: CGFloat
    let height: CGFloat
    let blurRadius: CGFloat

    var body: some View {
        Capsule(style: .continuous)
            .fill(color)
            .frame(width: width, height: height)
            .mask {
                LinearGradient(
                    colors: [.clear, .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .blur(radius: blurRadius)
    }
}

#Preview {
    ZStack {
        AppColor.Surface.canvas
            .ignoresSafeArea()

        VStack {
            ToastView(
                item: ToastItem(
                    message: "Your changes have been saved",
                    icon: "checkmark",
                    accentColor: .green
                ),
                configuration: ToastConfiguration(),
                availableWidth: 393,
                isDismissRequested: false,
                onOvershoot: {},
                onExitComplete: {}
            )
            .padding(.top, AppSpacing.xs)

            Spacer()
        }
    }
}
