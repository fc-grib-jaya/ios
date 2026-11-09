//
//  SankeyModel.swift
//  CattleFarmz
//
//  Created by Bomanarakasura on 09/11/26.
//

import SwiftUI

// MARK: - Public Model

/// A forest of SankeyItem values describes independent
/// source-to-leaf trees.
/// IDs must be globally unique.
/// Branch values are calculated from their leaves.
public struct SankeyItem: Identifiable {
    public let id: String
    public let title: String
    public let color: Color
    public let order: Int

    /// nil inherits the chart's showLabel.
    public let showLabel: Bool?
    public let children: [SankeyItem]

    private let leafValue: Double?

    // Leaf initializer
    public init(
        id: String,
        title: String,
        value: Double,
        color: Color,
        order: Int = 0,
        showLabel: Bool? = nil
    ) {
        precondition(
            value.isFinite && value > 0,
            "Leaf value must be positive and finite"
        )

        self.id = id
        self.title = title
        self.color = color
        self.order = order
        self.showLabel = showLabel
        self.children = []
        self.leafValue = value
    }

    // Branch initializer
    public init(
        id: String,
        title: String,
        color: Color,
        order: Int = 0,
        showLabel: Bool? = nil,
        children: [SankeyItem]
    ) {
        precondition(
            !children.isEmpty,
            "Branches must have at least one child"
        )

        self.id = id
        self.title = title
        self.color = color
        self.order = order
        self.showLabel = showLabel
        self.children = children
        self.leafValue = nil
    }

    public var value: Double {
        leafValue ?? children.reduce(0) { $0 + $1.value }
    }
}

// MARK: - Selection

public enum SankeySelection: Equatable {
    case node(id: String)
    case flow(sourceID: String, targetID: String)
}

// MARK: - Tree Flattening

/// A node placed on one level of the forest.
struct SankeyNode {
    let item: SankeyItem
    let level: Int
}

enum SankeyTree {
    /// Collects every item into its depth level.
    ///
    /// Nodes are ordered by `order`; equal orders keep
    /// their original input order.
    static func levels(_ roots: [SankeyItem]) -> [[SankeyNode]] {
        var levels: [[SankeyNode]] = []

        func walk(_ item: SankeyItem, level: Int) {
            if levels.count <= level {
                levels.append([])
            }

            levels[level].append(
                SankeyNode(item: item, level: level)
            )

            for child in item.children {
                walk(child, level: level + 1)
            }
        }

        for root in roots {
            walk(root, level: 0)
        }

        return levels.map { nodes in
            nodes
                .enumerated()
                .sorted { lhs, rhs in
                    lhs.element.item.order == rhs.element.item.order
                        ? lhs.offset < rhs.offset
                        : lhs.element.item.order < rhs.element.item.order
                }
                .map(\.element)
        }
    }
}
