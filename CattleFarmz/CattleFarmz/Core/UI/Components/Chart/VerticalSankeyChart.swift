//
//  VerticalSankeyChart.swift
//  CattleFarmz
//
//  Created by Bomanarakasura on 04/11/26.
//


import SwiftUI

// MARK: - Vertical Sankey View

/// Draws a Sankey forest top to bottom: each level is a row of
/// horizontal bars whose width is proportional to value.
public struct VerticalSankeyChart: View {
    public let data: [SankeyItem]
    public let showLabel: Bool
    public let levelSpacing: CGFloat
    public let minimumLeafWidth: CGFloat
    public let nodeGap: CGFloat
    public let horizontalPadding: CGFloat
    public let curveStrength: CGFloat
    public let onTapGesture: ((SankeySelection) -> Void)?

    public init(
        data: [SankeyItem],
        showLabel: Bool = true,
        levelSpacing: CGFloat = 126,
        minimumLeafWidth: CGFloat = 18,
        nodeGap: CGFloat = 12,
        horizontalPadding: CGFloat = 20,
        curveStrength: CGFloat = 0.48,
        onTapGesture: ((SankeySelection) -> Void)? = nil
    ) {
        self.data = data
        self.showLabel = showLabel
        self.levelSpacing = max(44, levelSpacing)
        self.minimumLeafWidth = max(1, minimumLeafWidth)
        self.nodeGap = max(0, nodeGap)
        self.horizontalPadding = max(0, horizontalPadding)
        self.curveStrength = min(1, max(0, curveStrength))
        self.onTapGesture = onTapGesture
    }

    private let barHeight: CGFloat = 12
    private let topInset: CGFloat = 40

    public var body: some View {
        let levels = SankeyTree.levels(data)
        let maxDepth = levels.count

        let diagramHeight =
            topInset
            + CGFloat(max(maxDepth - 1, 0)) * levelSpacing
            + 36

        GeometryReader { geometry in
            let widestCount = levels.map(\.count).max() ?? 0

            let total = data.reduce(0) {
                $0 + $1.value
            }

            let smallest = levels
                .flatMap { $0 }
                .map { $0.item.value }
                .min() ?? 1

            let valueWidth =
                total > 0 && smallest > 0
                ? CGFloat(total / smallest) * minimumLeafWidth
                : 0

            let minimumWidth =
                valueWidth
                + CGFloat(max(0, widestCount - 1)) * nodeGap
                + horizontalPadding * 2

            let width = max(
                geometry.size.width,
                minimumWidth
            )

            let layout = Self.makeLayout(
                levels: levels,
                width: width,
                total: total,
                nodeGap: nodeGap,
                horizontalPadding: horizontalPadding,
                levelSpacing: levelSpacing,
                topInset: topInset,
                barHeight: barHeight
            )

            ScrollView(.horizontal) {
                Canvas { context, _ in
                    draw(layout, context: &context)
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
                        for node in layout.nodes.reversed()
                        where node.bar
                            .insetBy(dx: -3, dy: -4)
                            .contains(location) {

                            onTapGesture(
                                .node(id: node.item.id)
                            )
                            return
                        }

                        // Last painted flow is visually on top.
                        for flow in layout.flows.reversed()
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
                    width: width,
                    height: diagramHeight
                )
                .accessibilityLabel(
                    "Vertical Sankey diagram"
                )
            }
            .scrollIndicators(.hidden)
        }
        .frame(height: diagramHeight)
    }

    // MARK: - Layout Types

    private struct PlacedNode {
        let item: SankeyItem
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

        let width: CGFloat
    }

    private struct Layout {
        var nodes: [PlacedNode] = []
        var flows: [PlacedFlow] = []
    }

    // MARK: - Layout Engine

    private static func makeLayout(
        levels: [[SankeyNode]],
        width: CGFloat,
        total: Double,
        nodeGap: CGFloat,
        horizontalPadding: CGFloat,
        levelSpacing: CGFloat,
        topInset: CGFloat,
        barHeight: CGFloat
    ) -> Layout {
        guard total > 0, total.isFinite else {
            return Layout()
        }

        let widestCount =
            levels.map(\.count).max() ?? 0

        let available = max(
            1,
            width
                - horizontalPadding * 2
                - CGFloat(max(widestCount - 1, 0)) * nodeGap
        )

        // One global scale ensures that the width
        // of every flow matches its value.
        let scale = available / CGFloat(total)

        var output = Layout()
        var positions: [String: PlacedNode] = [:]
        var ids = Set<String>()

        // Position every level independently.
        for (level, nodes) in levels.enumerated() {
            let widths = nodes.map {
                CGFloat($0.item.value) * scale
            }

            let sumWidths = widths.reduce(
                CGFloat.zero,
                +
            )

            let occupied =
                sumWidths
                + CGFloat(max(nodes.count - 1, 0)) * nodeGap

            var cursor = (width - occupied) / 2

            for (index, entry) in nodes.enumerated() {
                precondition(
                    ids.insert(entry.item.id).inserted,
                    "Sankey IDs must be unique"
                )

                let rect = CGRect(
                    x: cursor,
                    y: topInset + CGFloat(level) * levelSpacing,
                    width: widths[index],
                    height: barHeight
                )

                let placed = PlacedNode(
                    item: entry.item,
                    bar: rect
                )

                positions[entry.item.id] = placed
                output.nodes.append(placed)

                cursor += widths[index] + nodeGap
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

            // Sort only by order.
            let orderedChildren = item.children.sorted {
                $0.order < $1.order
            }

            var leftEdge = source.bar.minX

            for child in orderedChildren {
                guard let target = positions[child.id] else {
                    continue
                }

                let ribbonWidth = target.bar.width

                output.flows.append(
                    PlacedFlow(
                        sourceID: item.id,
                        targetID: child.id,
                        sourceColor: item.color,
                        targetColor: child.color,
                        startX: leftEdge + ribbonWidth / 2,
                        startY: source.bar.maxY,
                        endX: target.bar.midX,
                        endY: target.bar.minY,
                        width: ribbonWidth
                    )
                )

                leftEdge += ribbonWidth

                addFlows(from: child)
            }
        }

        for root in levels.first ?? [] {
            addFlows(from: root.item)
        }

        return output
    }

    // MARK: - Bezier Flow

    private func flowPath(
        _ flow: PlacedFlow
    ) -> Path {
        let half = flow.width / 2

        let control =
            (flow.endY - flow.startY) * curveStrength

        return Path { path in
            path.move(
                to: CGPoint(
                    x: flow.startX - half,
                    y: flow.startY
                )
            )

            // Left edge of ribbon
            path.addCurve(
                to: CGPoint(
                    x: flow.endX - half,
                    y: flow.endY
                ),
                control1: CGPoint(
                    x: flow.startX - half,
                    y: flow.startY + control
                ),
                control2: CGPoint(
                    x: flow.endX - half,
                    y: flow.endY - control
                )
            )

            path.addLine(
                to: CGPoint(
                    x: flow.endX + half,
                    y: flow.endY
                )
            )

            // Right edge of ribbon
            path.addCurve(
                to: CGPoint(
                    x: flow.startX + half,
                    y: flow.startY
                ),
                control1: CGPoint(
                    x: flow.endX + half,
                    y: flow.endY - control
                ),
                control2: CGPoint(
                    x: flow.startX + half,
                    y: flow.startY + control
                )
            )

            path.closeSubpath()
        }
    }

    // MARK: - Rendering

    private func draw(
        _ layout: Layout,
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
                            flow.targetColor.opacity(0.82)
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
            if node.item.showLabel ?? showLabel {
                let label = Text(
                    "\(node.item.title)  \(node.item.value.formatted())"
                )
                .font(
                    .system(
                        size: 11,
                        weight: .semibold,
                        design: .rounded
                    )
                )
                .foregroundStyle(.primary)

                context.draw(
                    label,
                    at: CGPoint(
                        x: node.bar.midX,
                        y: node.bar.minY - 7
                    ),
                    anchor: .bottom
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VerticalSankeyChart(
        data: [
            SankeyItem(
                id: "a",
                title: "A",
                color: .purple,
                order: 0,
                children: [
                    SankeyItem(
                        id: "a1",
                        title: "A1",
                        color: .cyan,
                        order: 1,
                        children: [
                            SankeyItem(
                                id: "a11",
                                title: "A1.1",
                                value: 20,
                                color: .mint,
                                order: 1
                            ),
                            SankeyItem(
                                id: "a12",
                                title: "A1.2",
                                value: 30,
                                color: .orange,
                                order: 0
                            )
                        ]
                    ),
                    SankeyItem(
                        id: "a2",
                        title: "A2",
                        value: 15,
                        color: .pink,
                        order: 3
                    )
                ]
            ),

            SankeyItem(
                id: "b",
                title: "B",
                color: .green,
                order: 1,
                children: [
                    SankeyItem(
                        id: "b1",
                        title: "B1",
                        value: 30,
                        color: .teal,
                        order: 2
                    ),
                    SankeyItem(
                        id: "b2",
                        title: "B2",
                        value: 20,
                        color: .indigo,
                        order: 2
                    )
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
    .padding()
    .preferredColorScheme(.dark)
}
