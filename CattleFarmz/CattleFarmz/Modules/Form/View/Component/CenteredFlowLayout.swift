//
//  CenteredFlowLayout.swift
//  CattleFarmz
//
//  Created by Dylan Amadeus on 16/11/26.
//

import SwiftUI

struct CenteredFlowLayout: Layout {
    var horizontalSpacing: CGFloat
    var verticalSpacing: CGFloat

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func makeRows(sizes: [CGSize], maxWidth: CGFloat) -> [Row] {
        var rows: [Row] = []
        var row = Row()

        for (index, size) in sizes.enumerated() {
            if !row.indices.isEmpty,
               row.width + horizontalSpacing + size.width > maxWidth {
                rows.append(row)
                row = Row()
            }

            if !row.indices.isEmpty {
                row.width += horizontalSpacing
            }

            row.indices.append(index)
            row.width += size.width
            row.height = max(row.height, size.height)
        }

        if !row.indices.isEmpty {
            rows.append(row)
        }

        return rows
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let rows = makeRows(sizes: sizes, maxWidth: proposal.width ?? .infinity)
        let height = rows.reduce(CGFloat.zero) { $0 + $1.height }
            + CGFloat(max(0, rows.count - 1)) * verticalSpacing

        return CGSize(
            width: proposal.width ?? (rows.map(\.width).max() ?? 0),
            height: height
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let rows = makeRows(sizes: sizes, maxWidth: bounds.width)
        var y = bounds.minY

        for row in rows {
            var x = bounds.midX - row.width / 2

            for index in row.indices {
                let size = sizes[index]
                subviews[index].place(
                    at: CGPoint(x: x, y: y + (row.height - size.height) / 2),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(width: size.width, height: size.height)
                )
                x += size.width + horizontalSpacing
            }

            y += row.height + verticalSpacing
        }
    }
}
