import Testing
@testable import CattleFarmz

@MainActor
struct FeedAmountValidationTests {
    private func makeViewModel() -> RationPlanningViewModel {
        let data = RationEvaluationPreviewData.result
        let vm = RationPlanningViewModel(
            feedProvider: { data.items.map(\.ingredient) },
            calculator: ManualRationCalculator { _ in data.requirements }
        )
        vm.load()
        for feed in vm.feeds.prefix(2) { vm.toggleFeed(feed) }
        return vm
    }

    @Test func emptyInputsWarnOnlyAfterEvaluation() throws {
        let vm = makeViewModel()
        let feed = try #require(vm.selectedFeeds.first)
        vm.updateAmount("", for: feed)
        #expect(!vm.hasMissingAmount(for: feed))
        vm.calculate()
        #expect(vm.hasMissingAmount(for: feed))
        #expect(vm.result == nil)
    }

    @Test func focusingOneInputClearsOnlyItsWarningUntilNextEvaluation() throws {
        let vm = makeViewModel()
        let first = try #require(vm.selectedFeeds.first)
        let second = try #require(vm.selectedFeeds.dropFirst().first)
        vm.calculate()
        vm.clearAmountWarning(for: first.id)
        #expect(!vm.hasMissingAmount(for: first))
        #expect(vm.hasMissingAmount(for: second))
        vm.updateAmount("1", for: first)
        vm.updateAmount("", for: first)
        #expect(!vm.hasMissingAmount(for: first))
        vm.calculate()
        #expect(vm.hasMissingAmount(for: first))
    }

    @Test func fillingAndRemovingInputsClearsTheirWarnings() throws {
        let vm = makeViewModel()
        let first = try #require(vm.selectedFeeds.first)
        let second = try #require(vm.selectedFeeds.dropFirst().first)
        vm.calculate()
        vm.updateAmount("10", for: first)
        #expect(!vm.hasMissingAmount(for: first))
        #expect(vm.hasMissingAmount(for: second))
        vm.removeFeed(second)
        #expect(!vm.hasMissingAmount(for: second))
        vm.toggleFeed(second)
        #expect(!vm.hasMissingAmount(for: second))
    }
}
