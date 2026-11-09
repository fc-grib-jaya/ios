//
//  HorizontalSankeyChart.swift
//  CattleFarmz
//
//  Created by Bomanarakasura on 09/11/26.
//

import CoreText
import SwiftUI

// MARK: - Horizontal Sankey View

/// Draws a Sankey forest left to right: each level is a column of
/// vertical bars whose height is proportional to value.
///
/// Labels live outside the bars, never over the ribbons:
/// every level but the last draws its label above the bar's top
/// edge, with the value under the title. The last level draws its
/// label to the right of the bar instead, so it can never clip the
/// outgoing edge of the chart.
///
/// The view always fits the height proposed by its parent. Bars that
/// would become invisible at the proportional scale are clamped to a
/// minimum thickness, so tall uneven trees (many tiny leaves) stay in
/// frame instead of exploding the layout.
public struct HorizontalSankeyChart: View {
    public let data: [SankeyItem]
    public let showLabel: Bool
    public let levelSpacing: CGFloat
    public let minimumLeafThickness: CGFloat
    public let nodeGap: CGFloat
    public let verticalPadding: CGFloat
    public let horizontalPadding: CGFloat
    public let curveStrength: CGFloat
    /// How much taller than the proposed height the content may grow
    /// before it is compressed to fit. `1.0` fits the frame exactly;
    /// `1.3` lets the content be up to 30% taller (scrollable).
    public let maxHeightScale: CGFloat
    public let onTapGesture: ((SankeySelection) -> Void)?

    public init(
        data: [SankeyItem],
        showLabel: Bool = true,
        levelSpacing: CGFloat = 140,
        minimumLeafThickness: CGFloat = 14,
        nodeGap: CGFloat = 12,
        verticalPadding: CGFloat = 20,
        horizontalPadding: CGFloat = 16,
        curveStrength: CGFloat = 0.48,
        maxHeightScale: CGFloat = 1.0,
        onTapGesture: ((SankeySelection) -> Void)? = nil
    ) {
        self.data = data
        self.showLabel = showLabel
        self.levelSpacing = max(44, levelSpacing)
        self.minimumLeafThickness = max(1, minimumLeafThickness)
        self.nodeGap = max(0, nodeGap)
        self.verticalPadding = max(0, verticalPadding)
        self.horizontalPadding = max(0, horizontalPadding)
        self.curveStrength = min(1, max(0, curveStrength))
        self.maxHeightScale = max(1, maxHeightScale)
        self.onTapGesture = onTapGesture
    }

    private let barWidth: CGFloat = 12

    /// Space between a label block and the bar it describes.
    private let labelInset: CGFloat = 6

    public var body: some View {
        let levels = SankeyTree.levels(data)
        let total = data.reduce(0) { $0 + $1.value }
        let lastLevel = max(levels.count - 1, 0)

        GeometryReader { geometry in
            let result = Self.makeLayout(
                levels: levels,
                containerSize: geometry.size,
                total: total,
                lastLevel: lastLevel,
                showLabel: showLabel,
                nodeGap: nodeGap,
                verticalPadding: verticalPadding,
                horizontalPadding: horizontalPadding,
                levelSpacing: levelSpacing,
                minimumLeafThickness: minimumLeafThickness,
                maxHeightScale: maxHeightScale,
                barWidth: barWidth,
                labelInset: labelInset
            )

            ScrollView([.horizontal, .vertical]) {
                Canvas { context, _ in
                    draw(
                        result.layout,
                        lastLevel: lastLevel,
                        context: &context
                    )
                }
                .contentShape(Rectangle())
                .gesture(
                    SpatialTapGesture().onEnded { tap in
                        guard let onTapGesture else {
                            return
                        }

                        let location = tap.location

                        // Nodes are above flows.
                        // Hit-test nodes first.
                        for node in result.layout.nodes.reversed()
                        where node.bar
                            .insetBy(dx: -3, dy: -4)
                            .contains(location)
                        {

                            onTapGesture(.node(id: node.item.id))
                            return
                        }

                        // Last painted flow is visually on top.
                        for flow in result.layout.flows.reversed()
                        where flowPath(flow).contains(location) {

                            onTapGesture(
                                .flow(
                                    sourceID: flow.sourceID,
                                    targetID: flow.targetID
                                )
                            )
                            return
                        }
                    }
                )
                .frame(
                    width: result.size.width,
                    height: result.size.height
                )
                .accessibilityLabel("Horizontal Sankey diagram")
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Layout Types

    private struct PlacedNode {
        let item: SankeyItem
        let level: Int
        let bar: CGRect
    }

    private struct PlacedFlow {
        let sourceID: String
        let targetID: String

        let sourceColor: Color
        let targetColor: Color

        let startX: CGFloat
        let startY: CGFloat

        let endX: CGFloat
        let endY: CGFloat

        let thickness: CGFloat
    }

    private struct Layout {
        var nodes: [PlacedNode] = []
        var flows: [PlacedFlow] = []
    }

    private struct Result {
        var size: CGSize
        var layout: Layout
    }

    // MARK: - Layout Engine

    private static func makeLayout(
        levels: [[SankeyNode]],
        containerSize: CGSize,
        total: Double,
        lastLevel: Int,
        showLabel: Bool,
        nodeGap: CGFloat,
        verticalPadding: CGFloat,
        horizontalPadding: CGFloat,
        levelSpacing: CGFloat,
        minimumLeafThickness: CGFloat,
        maxHeightScale: CGFloat,
        barWidth: CGFloat,
        labelInset: CGFloat
    ) -> Result {
        guard
            total > 0,
            total.isFinite,
            let firstLevel = levels.first
        else {
            return Result(size: containerSize, layout: Layout())
        }

        let labels = labelMetrics(
            levels: levels,
            lastLevel: lastLevel,
            showLabel: showLabel,
            labelInset: labelInset
        )

        // The first column can overhang to the left because its
        // labels are centred over the bar. The last column needs
        // room to the right for its side labels.
        let leadingInset = horizontalPadding + labels.leadingInset
        let trailingInset = horizontalPadding + labels.trailingInset

        let width = max(
            containerSize.width,
            leadingInset
                + barWidth
                + CGFloat(lastLevel) * levelSpacing
                + trailingInset
        )

        // Reserve the gap between stacked nodes, large enough to
        // hold the label drawn above each bar (or beside it on the
        // last level) so adjacent labels never collide.
        let gaps = levels.enumerated().map { level, nodes -> CGFloat in
            if level < lastLevel, labels.columnHeight[level] > 0 {
                return max(nodeGap, labels.columnHeight[level] + labelInset + 2)
            }

            if level == lastLevel, labels.sideLabelHeight > 0 {
                return max(nodeGap, labels.sideLabelHeight + labelInset)
            }

            return nodeGap
        }

        let gapsTotal = levels.enumerated().reduce(CGFloat.zero) {
            $0 + gaps[$1.offset] * CGFloat(max($1.element.count - 1, 0))
        }

        // Labels of the first bars must not leave the frame.
        let topReserve = labels.columnHeight.max() ?? 0

        // The densest column decides the smallest usable bar thickness:
        // its minimums plus its gaps must fit the container.
        let densestIndex = levels.indices.max {
            levels[$0].count < levels[$1].count
        } ?? 0
        let densestCount = max(levels[densestIndex].count, 1)
        let densestGap = gaps[densestIndex]

        let floorHeight =
            verticalPadding * 2
            + topReserve
            + densestGap * CGFloat(densestCount - 1)
            + CGFloat(densestCount)

        // Fit-to-container: the content stays close to the proposed
        // height, but may grow up to `maxHeightScale` times taller
        // (the view scrolls the overflow). Bars that would disappear
        // at the proportional scale are clamped to a minimum thickness
        // so they stay visible and tappable; when even the requested
        // minimums cannot fit, the effective minimum shrinks toward 1pt.
        let allowedHeight = max(
            containerSize.height * maxHeightScale,
            floorHeight
        )

        // Height the layout would need if every bar got the full
        // requested minimum thickness.
        let comfortableHeight =
            verticalPadding * 2
            + topReserve
            + gapsTotal
            + CGFloat(densestCount) * minimumLeafThickness

        let height = min(
            allowedHeight,
            max(containerSize.height, comfortableHeight)
        )

        var effectiveMinimum = height >= comfortableHeight
            ? minimumLeafThickness
            : max(
                1,
                min(
                    minimumLeafThickness,
                    (height - verticalPadding * 2 - topReserve
                        - densestGap * CGFloat(densestCount - 1))
                        / CGFloat(densestCount)
                )
            )

        // Per-column water-filling: each level fills its own vertical
        // budget, so a dense last level cannot starve the upper levels
        // (and vice versa). Within a column, bars below the minimum
        // are clamped so they stay visible, the remaining bars share
        // what is left proportionally, and the minimum shrinks until
        // the column fits (big bars take more than the minimum, so
        // the initial feasibility estimate alone can overflow).
        var scales: [CGFloat] = Array(repeating: 0, count: levels.count)
        var minimums: [CGFloat] = Array(
            repeating: effectiveMinimum,
            count: levels.count
        )

        for (level, nodes) in levels.enumerated() {
            let budget = max(
                1,
                height
                    - verticalPadding * 2
                    - topReserve
                    - gaps[level] * CGFloat(max(nodes.count - 1, 0))
            )
            let columnTotal = nodes.reduce(0.0) { $0 + $1.item.value }
            let idealScale = columnTotal > 0
                ? budget / CGFloat(columnTotal)
                : 0

            var minimum = min(
                minimumLeafThickness,
                max(1, budget / CGFloat(max(nodes.count, 1)))
            )
            var scale = idealScale

            for _ in 0..<8 {
                var clampedThickness: CGFloat = 0
                var clampedValue: Double = 0
                for node in nodes {
                    if CGFloat(node.item.value) * idealScale < minimum {
                        clampedThickness += minimum
                        clampedValue += node.item.value
                    }
                }

                let proportionalValue = columnTotal - clampedValue
                scale = proportionalValue > 0
                    ? max(0, budget - clampedThickness)
                        / CGFloat(proportionalValue)
                    : idealScale

                let sum = nodes.reduce(CGFloat.zero) {
                    $0 + max(CGFloat($1.item.value) * scale, minimum)
                }

                let overflow = sum - budget
                guard overflow > 0.5 else { break }
                minimum = max(
                    1,
                    minimum - overflow / CGFloat(max(nodes.count, 1))
                )
            }

            scales[level] = scale
            minimums[level] = minimum
        }

        // Provisional thickness per node from its column's water-filling.
        var thicknessByID: [String: CGFloat] = [:]
        for (level, nodes) in levels.enumerated() {
            for node in nodes {
                thicknessByID[node.item.id] = max(
                    CGFloat(node.item.value) * scales[level],
                    minimums[level]
                )
            }
        }

        // Bottom-up: a branch bar spans exactly its children's ribbon
        // thicknesses, so every parent visually covers its whole
        // decomposition (ribbons stack contiguously from the parent's
        // top edge). Without this, per-column scaling breaks the
        // parent-child coverage that makes a Sankey readable.
        for nodes in levels.reversed() {
            for node in nodes where !node.item.children.isEmpty {
                let children = node.item.children.reduce(CGFloat.zero) {
                    $0 + (thicknessByID[$1.id] ?? 0)
                }
                thicknessByID[node.item.id] = children
            }
        }

        var layout = Layout()
        var positions: [String: PlacedNode] = [:]
        var ids = Set<String>()

        for (level, nodes) in levels.enumerated() {
            let gap = gaps[level]

            let thicknesses = nodes.map {
                thicknessByID[$0.item.id] ?? minimums[level]
            }

            let sumThicknesses = thicknesses.reduce(CGFloat.zero, +)

            let columnAvailable =
                height
                - verticalPadding * 2
                - topReserve
                - gap * CGFloat(max(nodes.count - 1, 0))

            // Centre the column inside the space it can use.
            var cursor =
                verticalPadding
                + topReserve
                + max(0, columnAvailable - sumThicknesses) / 2

            for (index, entry) in nodes.enumerated() {
                precondition(
                    ids.insert(entry.item.id).inserted,
                    "Sankey IDs must be unique"
                )

                let bar = CGRect(
                    x: leadingInset + CGFloat(level) * levelSpacing,
                    y: cursor,
                    width: barWidth,
                    height: thicknesses[index]
                )

                let placed = PlacedNode(
                    item: entry.item,
                    level: level,
                    bar: bar
                )

                positions[entry.item.id] = placed
                layout.nodes.append(placed)

                cursor += thicknesses[index] + gap
            }
        }

        // Build all parent-child ribbons.
        func addFlows(from item: SankeyItem) {
            guard
                let source = positions[item.id],
                !item.children.isEmpty
            else {
                return
            }

            let orderedChildren = item.children.sorted {
                $0.order < $1.order
            }

            var topEdge = source.bar.minY

            for child in orderedChildren {
                guard let target = positions[child.id] else {
                    continue
                }

                let ribbonThickness = target.bar.height

                layout.flows.append(
                    PlacedFlow(
                        sourceID: item.id,
                        targetID: child.id,
                        sourceColor: item.color,
                        targetColor: child.color,
                        startX: source.bar.maxX,
                        startY: topEdge + ribbonThickness / 2,
                        endX: target.bar.minX,
                        endY: target.bar.midY,
                        thickness: ribbonThickness
                    )
                )

                topEdge += ribbonThickness

                addFlows(from: child)
            }
        }

        for root in firstLevel {
            addFlows(from: root.item)
        }

        return Result(
            size: CGSize(width: width, height: height),
            layout: layout
        )
    }

    // MARK: - Label Metrics

    private struct LabelMetrics {
        /// Half of the widest label of the first column.
        var leadingInset: CGFloat = 0
        /// Width of the widest label of the last column.
        var trailingInset: CGFloat = 0
        /// Height of the tallest label drawn above a bar per column.
        var columnHeight: [CGFloat] = []
        /// Height of the single-line label drawn beside a last-level bar.
        var sideLabelHeight: CGFloat = 0
    }

    private static func labelMetrics(
        levels: [[SankeyNode]],
        lastLevel: Int,
        showLabel: Bool,
        labelInset: CGFloat
    ) -> LabelMetrics {
        var metrics = LabelMetrics(
            columnHeight: Array(repeating: 0, count: levels.count)
        )

        for (level, nodes) in levels.enumerated() {
            for node in nodes where node.item.showLabel ?? showLabel {
                let size = labelSize(for: node.item)

                if level == lastLevel {
                    let side = sideLabelSize(for: node.item)

                    metrics.trailingInset = max(
                        metrics.trailingInset,
                        side.width + labelInset + 4
                    )
                    metrics.sideLabelHeight = max(
                        metrics.sideLabelHeight,
                        side.height
                    )
                } else {
                    metrics.columnHeight[level] = max(
                        metrics.columnHeight[level],
                        size.height
                    )
                }

                if level == 0, level < lastLevel {
                    metrics.leadingInset = max(
                        metrics.leadingInset,
                        size.width / 2
                    )
                }
            }
        }

        return metrics
    }

    // MARK: - Label Measurement

    private static let titlePointSize: CGFloat = 11
    private static let valuePointSize: CGFloat = 10

    private static func labelSize(
        for item: SankeyItem
    ) -> (width: CGFloat, height: CGFloat) {
        let title = measure(
            item.title,
            pointSize: titlePointSize,
            traits: .traitBold
        )

        let value = measure(
            item.value.formatted(),
            pointSize: valuePointSize,
            traits: []
        )

        return (
            width: max(title.width, value.width),
            height: title.height + value.height
        )
    }

    /// Single-line label drawn beside a last-level bar: title and
    /// value on one line. Its height drives the last level's row gap
    /// so adjacent labels never collide.
    private static func sideLabelSize(
        for item: SankeyItem
    ) -> (width: CGFloat, height: CGFloat) {
        let title = measure(
            item.title,
            pointSize: titlePointSize,
            traits: .traitBold
        )

        let value = measure(
            item.value.formatted(),
            pointSize: valuePointSize,
            traits: []
        )

        return (
            width: title.width + value.width + 6,
            height: max(title.height, value.height)
        )
    }

    private static func measure(
        _ text: String,
        pointSize: CGFloat,
        traits: CTFontSymbolicTraits
    ) -> (width: CGFloat, height: CGFloat) {
        guard
            let base = CTFontCreateUIFontForLanguage(
                .system,
                pointSize,
                nil
            )
        else {
            return (0, 0)
        }

        let font =
            traits.isEmpty
            ? base
            : CTFontCreateCopyWithSymbolicTraits(
                base,
                pointSize,
                nil,
                traits,
                traits
            ) ?? base

        let attributed = NSAttributedString(
            string: text,
            attributes: [
                NSAttributedString.Key(kCTFontAttributeName as String): font
            ]
        )

        let line = CTLineCreateWithAttributedString(attributed)

        let width = CTLineGetTypographicBounds(line, nil, nil, nil)

        let height =
            CTFontGetAscent(font)
            + CTFontGetDescent(font)
            + CTFontGetLeading(font)

        return (ceil(CGFloat(width)), ceil(height))
    }

    // MARK: - Bezier Flow

    private func flowPath(
        _ flow: PlacedFlow
    ) -> Path {
        let half = flow.thickness / 2

        let control =
            (flow.endX - flow.startX) * curveStrength

        return Path { path in
            path.move(
                to: CGPoint(
                    x: flow.startX,
                    y: flow.startY - half
                )
            )

            // Top edge of ribbon
            path.addCurve(
                to: CGPoint(
                    x: flow.endX,
                    y: flow.endY - half
                ),
                control1: CGPoint(
                    x: flow.startX + control,
                    y: flow.startY - half
                ),
                control2: CGPoint(
                    x: flow.endX - control,
                    y: flow.endY - half
                )
            )

            path.addLine(
                to: CGPoint(
                    x: flow.endX,
                    y: flow.endY + half
                )
            )

            // Bottom edge of ribbon
            path.addCurve(
                to: CGPoint(
                    x: flow.startX,
                    y: flow.startY + half
                ),
                control1: CGPoint(
                    x: flow.endX - control,
                    y: flow.endY + half
                ),
                control2: CGPoint(
                    x: flow.startX + control,
                    y: flow.startY + half
                )
            )

            path.closeSubpath()
        }
    }

    // MARK: - Labels

    private static func titleText(_ title: String) -> Text {
        Text(title)
            .font(.system(size: titlePointSize, weight: .semibold))
            .foregroundStyle(.primary)
    }

    private static func valueText(_ value: Double) -> Text {
        Text(value.formatted())
            .font(.system(size: valuePointSize, weight: .medium))
            .foregroundStyle(.secondary)
    }

    /// One-line "Title value" label for the last level.
    private static func sideLabel(for item: SankeyItem) -> Text {
        titleText(item.title)
            + Text(" ")
            + valueText(item.value)
    }

    /// Height of the stacked label block.
    private static func labelHeight(
        for item: SankeyItem
    ) -> (title: CGFloat, value: CGFloat) {
        (
            title: measure(
                item.title,
                pointSize: titlePointSize,
                traits: .traitBold
            ).height,
            value: measure(
                item.value.formatted(),
                pointSize: valuePointSize,
                traits: []
            ).height
        )
    }

    // MARK: - Rendering

    private func draw(
        _ layout: Layout,
        lastLevel: Int,
        context: inout GraphicsContext
    ) {
        // Draw ribbons first.
        for flow in layout.flows {
            context.fill(
                flowPath(flow),
                with: .linearGradient(
                    Gradient(
                        colors: [
                            flow.sourceColor.opacity(0.82),
                            flow.targetColor.opacity(0.82),
                        ]
                    ),
                    startPoint: CGPoint(
                        x: flow.startX,
                        y: flow.startY
                    ),
                    endPoint: CGPoint(
                        x: flow.endX,
                        y: flow.endY
                    )
                )
            )
        }

        // Draw nodes above ribbons.
        for node in layout.nodes {
            context.fill(
                Path(
                    roundedRect: node.bar,
                    cornerRadius: 3
                ),
                with: .color(node.item.color)
            )

            // Node label overrides global preference.
            guard node.item.showLabel ?? showLabel else {
                continue
            }

            if node.level == lastLevel {
                // Last level: the bar is the separation line, so its
                // single-line label sits beside it, vertically centred.
                context.draw(
                    Self.sideLabel(for: node.item),
                    at: CGPoint(
                        x: node.bar.maxX + labelInset,
                        y: node.bar.midY
                    ),
                    anchor: .leading
                )
            } else {
                // Everything else: label sits above the bar's top
                // edge, value under the title.
                let heights = Self.labelHeight(for: node.item)
                let bottom = node.bar.minY - labelInset
                let x = node.bar.midX

                context.draw(
                    Self.titleText(node.item.title),
                    at: CGPoint(x: x, y: bottom - heights.value),
                    anchor: .bottom
                )

                context.draw(
                    Self.valueText(node.item.value),
                    at: CGPoint(x: x, y: bottom),
                    anchor: .bottom
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HorizontalSankeyChart(
        data: [
            SankeyItem(
                id: "a",
                title: "Daging",
                color: AppColor.Button.Secondary.foreground,
                order: 0,
                children: [
                    SankeyItem(
                        id: "a1",
                        title: "Karkas",
                        color: .pink,
                        order: 1,
                        children: [
                            SankeyItem(
                                id: "a1.1",
                                title: "Daging",
                                value: 105,
                                color: AppColor.Button.Secondary
                                    .pressedBackground,
                                order: 2
                            ),
                            SankeyItem(
                                id: "a1.2",
                                title: "Tulang",
                                value: 64,
                                color: AppColor.Button.Secondary
                                    .pressedBackground,
                                order: 2
                            ),
                        ]
                    ),
                    SankeyItem(
                        id: "a2",
                        title: "Non Karkas",
                        color: AppColor.Button.Secondary.pressedBackground,
                        order: 1,
                        children: [
                            SankeyItem(
                                id: "a2.1",
                                title: "Daging",
                                value: 105,
                                color: AppColor.Button.Secondary
                                    .pressedBackground,
                                order: 2
                            ),
                            SankeyItem(
                                id: "a2.2",
                                title: "Tulang",
                                value: 64,
                                color: AppColor.Button.Secondary
                                    .pressedBackground,
                                order: 2
                            ),
                        ]
                    ),
                ]
            )
        ],
        showLabel: true,
        onTapGesture: { selection in
            switch selection {
            case .node(let id):
                print("Tapped node:", id)

            case .flow(let sourceID, let targetID):
                print(
                    "Tapped flow:",
                    sourceID,
                    "->",
                    targetID
                )
            }
        }
    )
    .frame(height: 360)
    .padding()
    .preferredColorScheme(.dark)
}
