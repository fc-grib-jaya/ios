//
//  FeedCatalogSeedState.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 05/11/26.
//


import SwiftData

@Model
final class FeedCatalogSeedState {
    @Attribute(.unique)
    var key: String

    var version: Int

    init(
        key: String = "feed-catalog",
        version: Int
    ) {
        self.key = key
        self.version = version
    }
}