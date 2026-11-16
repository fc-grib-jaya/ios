//
//  OnboardingFeedPlanView.swift
//  CattleFarmz
//

import Combine
import SwiftUI

/// Custom content for the feed-planning onboarding screen: a stacked deck
/// of three gradient-fading cards. On entrance the deck slides up from the
/// bottom with a small overshoot; every second the front card is discarded
/// downward to reveal the next one, looping back to the first.
struct OnboardingFeedPlanView: View {
    /// True while this onboarding page is the selected one. The visual
    /// stays hidden until then so a partial swipe does not reveal it early.
    var isActive: Bool = false

    /// Bounds the visual so it does not stretch to the full screen height.
    private let containerHeight: CGFloat = 320
    /// Shared width; every image renders at exactly this width, so the
    /// next card behind never appears at a different size.
    private let cardWidth: CGFloat = 300

    /// Card names, frontmost first. A discarded card is moved to the back.
    @State private var deck = ["3-1", "3-2", "3-3"]
    /// The card currently animating out through the bottom.
    @State private var discarding: String?
    /// The card winding up (lifted slightly) right before its discard.
    @State private var windingUp: String?
    /// Drives the entrance slide-up.
    @State private var appeared = false

    private let cycleTimer = Timer.publish(
        every: 1.5,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        ZStack(alignment: .top) {
            // Reversed so the front of the deck renders on top.
            ForEach(deck.enumerated().reversed(), id: \.element) { _, name in
                card(name)
                    .offset(y: offset(for: name))
                    .opacity(opacity(for: name))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: containerHeight)
        // Fixed fade over the card bottoms: transparent at top blending
        // into the page background so the cards melt into it.
        .overlay(alignment: .bottom) {
            LinearGradient(
                stops: [
                    Gradient.Stop(color: .clear, location: 0),
                    Gradient.Stop(
                        color: AppColor.Surface.canvas,
                        location: 1
                    ),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: containerHeight * 0.5)
            .allowsHitTesting(false)
        }
        .onAppear { syncAppeared() }
        .onChange(of: isActive) { syncAppeared() }
        .onReceive(cycleTimer) { _ in discardFront() }
    }

    private func syncAppeared() {
        // Damping fraction below 1 gives a small overshoot on the slide-up.
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            appeared = isActive
        }
    }

    /// Vertical offset of a card: below the container before the entrance
    /// and while being discarded down, lifted while winding up, stacked in
    /// place otherwise.
    private func offset(for name: String) -> CGFloat {
        if !appeared || discarding == name {
            return containerHeight
        }
        if windingUp == name {
            return -24
        }
        return 0
    }

    /// Cards fade while moving so the deck works without a clipping
    /// container: waiting cards are invisible before the entrance and a
    /// discarded card fades out as it slides down.
    private func opacity(for name: String) -> Double {
        if !appeared || discarding == name {
            return 0
        }
        return 1
    }

    /// Lifts the front card slightly, then slides it down out of view and
    /// moves it to the back of the deck without animation so the cycle can
    /// repeat.
    private func discardFront() {
        guard appeared, isActive, discarding == nil, windingUp == nil,
              let front = deck.first else {
            return
        }
        // Wind up: a quick lift before the discard.
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            windingUp = front
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.85)) {
                windingUp = nil
                discarding = front
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    guard deck.first == front else { return }
                    deck.removeFirst()
                    deck.append(front)
                    discarding = nil
                }
            }
        }
    }

    /// Image card with a fixed frame: every card is the same width and
    /// height, top-aligned so the image content is cropped only at the
    /// bottom, where the container gradient fades it out.
    private func card(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(
                width: cardWidth,
                height: containerHeight,
                alignment: .top
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 36, style: .continuous)
            )
    }
}

#Preview {
    OnboardingFeedPlanView(isActive: true)
        .padding(AppSpacing.massive)
        .background(AppColor.Surface.canvas)
}
