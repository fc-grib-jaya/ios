//
//  BundledFeedCSVReader.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 05/11/26.
//


import Foundation

@MainActor
protocol FeedCSVReading {
    func read() throws -> String
}

struct BundledFeedCSVReader: FeedCSVReading {
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func read() throws -> String {
        guard let url = bundle.url(
            forResource: "tabeldatapakan",
            withExtension: "csv"
        ) else {
            throw ReadError.fileNotFound
        }

        return try String(
            contentsOf: url,
            encoding: .utf8
        )
    }

    enum ReadError: LocalizedError {
        case fileNotFound

        var errorDescription: String? {
            switch self {
            case .fileNotFound:
                return "The bundled feed CSV could not be found."
            }
        }
    }
}
