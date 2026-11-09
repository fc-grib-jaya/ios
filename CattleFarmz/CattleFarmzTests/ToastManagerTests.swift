//
//  ToastManagerTests.swift
//  CattleFarmzTests
//

import Foundation
import Testing
@testable import CattleFarmz

@MainActor
struct ToastManagerTests {
    @Test
    func presentsTheFirstToastImmediately() {
        let manager = ToastManager()

        manager.show("Saved")

        #expect(manager.current?.message == "Saved")
        #expect(manager.exitRequestID == nil)
    }

    @Test
    func keepsLaterRequestsInFifoOrder() throws {
        let manager = ToastManager()
        manager.show("First")
        manager.show("Second")
        manager.show("Third")

        #expect(manager.current?.message == "First")

        let first = try #require(manager.current)
        manager.finish(first.id)
        #expect(manager.current?.message == "Second")

        let second = try #require(manager.current)
        manager.finish(second.id)
        #expect(manager.current?.message == "Third")

        let third = try #require(manager.current)
        manager.finish(third.id)
        #expect(manager.current == nil)
    }

    @Test
    func requestsExitForTheActiveToastOnly() throws {
        let manager = ToastManager()
        manager.show("First")
        manager.show("Second")

        manager.dismissCurrent()

        let first = try #require(manager.current)
        #expect(manager.exitRequestID == first.id)
        // The next toast waits for the exit animation to complete.
        #expect(manager.current?.message == "First")
    }

    @Test
    func ignoringAFinishForAnUnknownToastKeepsTheQueueMoving() throws {
        let manager = ToastManager()
        manager.show("First")
        manager.show("Second")
        let first = try #require(manager.current)

        manager.finish(UUID())

        #expect(manager.current?.id == first.id)

        manager.finish(first.id)
        #expect(manager.current?.message == "Second")
    }

    @Test
    func duplicateFinishAdvancesTheQueueOnce() throws {
        let manager = ToastManager()
        manager.show("First")
        manager.show("Second")
        manager.show("Third")
        let first = try #require(manager.current)

        manager.finish(first.id)
        manager.finish(first.id)

        #expect(manager.current?.message == "Second")
    }

    @Test
    func staleFinishCannotDismissTheNextToast() throws {
        let manager = ToastManager()
        manager.show("First")
        manager.show("Second")
        let first = try #require(manager.current)
        manager.finish(first.id)

        manager.finish(first.id)

        #expect(manager.current?.message == "Second")
    }

    @Test
    func dismissAllClearsTheQueueAndRequestsExit() throws {
        let manager = ToastManager()
        manager.show("First")
        manager.show("Second")
        manager.show("Third")
        let first = try #require(manager.current)

        manager.dismissAll()

        #expect(manager.exitRequestID == first.id)

        manager.finish(first.id)

        #expect(manager.current == nil)
        #expect(manager.exitRequestID == nil)
    }

    @Test
    func clearingTheExitRequestBelongsToTheActiveToast() throws {
        let manager = ToastManager()
        manager.show("First")
        manager.show("Second")
        let first = try #require(manager.current)

        manager.dismissCurrent()
        manager.finish(first.id)

        #expect(manager.current?.message == "Second")
        #expect(manager.exitRequestID == nil)
    }

    @Test
    func repeatedMessagesGetUniqueIdentifiers() {
        let manager = ToastManager()
        manager.show("Saved")
        manager.show("Saved")

        let first = manager.current?.id
        manager.dismissCurrent()
        if let first {
            manager.finish(first)
        }

        #expect(manager.current?.id != first)
        #expect(manager.current?.message == "Saved")
    }

    @Test
    func dismissWithoutAnActiveToastIsIgnored() {
        let manager = ToastManager()

        manager.dismissCurrent()
        manager.dismissAll()

        #expect(manager.current == nil)
        #expect(manager.exitRequestID == nil)
    }

    @Test
    func overshootFeedbackPlaysTheTickWithTheCowBell() {
        let haptics = RecordingHaptics()
        let sounds = RecordingSounds()
        let manager = ToastManager(haptics: haptics, sounds: sounds)

        manager.playOvershootFeedback()

        #expect(haptics.played == [.scanTick])
        #expect(sounds.played == [.cowBell])
    }

    @Test
    func ringsOncePerToastWhileTickingOnEveryOvershoot() throws {
        let haptics = RecordingHaptics()
        let sounds = RecordingSounds()
        let manager = ToastManager(haptics: haptics, sounds: sounds)
        manager.show("Saved")

        // The entrance animation reports two overshoots per toast.
        manager.playOvershootFeedback()
        manager.playOvershootFeedback()

        #expect(haptics.played == [.scanTick, .scanTick])
        #expect(sounds.played == [.cowBell])

        let first = try #require(manager.current)
        manager.finish(first.id)
        manager.show("Saved again")
        manager.playOvershootFeedback()

        #expect(sounds.played == [.cowBell, .cowBell])
    }
}

/// Records the patterns a toast manages to play.
@MainActor
private final class RecordingHaptics: HapticProviding {
    private(set) var played: [HapticPattern] = []

    func prepare() {}

    func play(_ pattern: HapticPattern) {
        played.append(pattern)
    }
}

@MainActor
private final class RecordingSounds: SoundPlaying {
    private(set) var played: [SoundEffect] = []

    func prepare() {}

    func play(_ effect: SoundEffect) {
        played.append(effect)
    }
}
