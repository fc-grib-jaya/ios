//
//  FeedCSVParser.swift
//  CattleFarmz
//
//  Created by Muhamad Yuan Sastro Dimianta on 05/11/26.
//

import Foundation

/// Converts bundled UTF-8 CSV text into domain values. Performs no I/O or persistence.
struct FeedCSVParser {
    private static let requiredColumns = [
        "Nama Pakan", "Jenis Hewan", "Kategori", "Protein (%)", "TDN (%)",
        "Ca (%)", "P (%)", "Mg (%)", "Fe (ppm)", "Cu (ppm)", "Zn (ppm)"
    ]

    func parse(_ text: String) throws -> [FeedIngredient] {
        let records = try readRecords(text)
        guard let first = records.first else { throw ParseError.emptyFile }
        let header = first.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard Set(header).count == header.count,
              Set(Self.requiredColumns).isSubset(of: Set(header)) else {
            throw ParseError.invalidHeader
        }
        let indices = Dictionary(uniqueKeysWithValues: header.enumerated().map { ($0.element, $0.offset) })
        var feeds: [FeedIngredient] = []

        for (offset, record) in records.dropFirst().enumerated() {
            let recordNumber = offset + 2
            guard record.count == header.count else {
                throw ParseError.invalidRecord(recordNumber, "Column count does not match the header.")
            }
            func value(_ column: String) -> String {
                record[indices[column]!].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            guard value("Jenis Hewan").lowercased() == "sapi" else { continue }

            func number(_ column: String, optional: Bool = false, maximum: Double? = nil) throws -> Double? {
                let raw = value(column)
                if optional && raw.isEmpty { return nil }
                guard let result = Double(raw), result.isFinite, result >= 0,
                      maximum.map({ result <= $0 }) ?? true else {
                    throw ParseError.invalidRecord(recordNumber, "Invalid value in \(column).")
                }
                return result
            }
            let name = value("Nama Pakan")
            guard !name.isEmpty else {
                throw ParseError.invalidRecord(recordNumber, "Feed name must not be empty.")
            }
            let category: FeedCategory
            switch value("Kategori").lowercased() {
            case "hijauan": category = .forage
            case "konsentrat": category = .concentrate
            case "mineral": category = .mineral
            default: throw ParseError.invalidRecord(recordNumber, "Unknown feed category.")
            }
            // Keeps duplicate names as separate records, matching the original cattle-row order.
            // IDs are stable for the same CSV ordering; later dataset updates need an explicit ID policy.
            let id = String(format: "cattle-source-%03d", feeds.count + 1)
            let nutrients = try NutrientContent(
                crudeProteinPercent: number("Protein (%)", maximum: 100)!,
                totalDigestibleNutrientsPercent: number("TDN (%)")!,
                calciumPercent: number("Ca (%)", optional: true, maximum: 100),
                phosphorusPercent: number("P (%)", optional: true, maximum: 100),
                magnesiumPercent: number("Mg (%)", optional: true, maximum: 100),
                ironPPM: number("Fe (ppm)", optional: true, maximum: 1_000_000),
                copperPPM: number("Cu (ppm)", optional: true, maximum: 1_000_000),
                zincPPM: number("Zn (ppm)", optional: true, maximum: 1_000_000)
            )
            let warningNames: Set<String> = ["bungkil biji kapas", "biji kapuk"]
            feeds.append(FeedIngredient(id: id, name: name, category: category,
                nutrients: nutrients, triggersGossypolWarning: warningNames.contains(name.lowercased())))
        }
        guard !feeds.isEmpty else { throw ParseError.emptyFile }
        return feeds
    }

    /// Handles comma-separated fields, quoted fields, escaped quotes, and embedded newlines.
    private func readRecords(_ text: String) throws -> [[String]] {
        var normalized = text.replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        if normalized.first == "\u{FEFF}" { normalized.removeFirst() }
        let characters = Array(normalized)
        var records: [[String]] = []
        var fields: [String] = []
        var field = ""
        var inQuotes = false
        var closedQuote = false
        var recordStarted = false
        var index = 0

        func finishField() {
            fields.append(field)
            field = ""
            closedQuote = false
        }
        func finishRecord() {
            finishField()
            if recordStarted { records.append(fields) }
            fields = []
            recordStarted = false
        }
        while index < characters.count {
            let character = characters[index]
            if inQuotes {
                if character == "\"" {
                    if index + 1 < characters.count, characters[index + 1] == "\"" {
                        field.append("\"")
                        index += 1
                    } else {
                        inQuotes = false
                        closedQuote = true
                    }
                } else { field.append(character) }
            } else if character == "," {
                recordStarted = true
                finishField()
            } else if character == "\n" {
                finishRecord()
            } else if character == "\"" {
                guard field.isEmpty, !closedQuote else { throw ParseError.malformedCSV }
                inQuotes = true
                recordStarted = true
            } else {
                guard !closedQuote else { throw ParseError.malformedCSV }
                field.append(character)
                recordStarted = true
            }
            index += 1
        }
        guard !inQuotes else { throw ParseError.malformedCSV }
        if recordStarted { finishRecord() }
        return records
    }

    enum ParseError: LocalizedError {
        case emptyFile
        case invalidHeader
        case malformedCSV
        case invalidRecord(Int, String)

        var errorDescription: String? {
            switch self {
            case .emptyFile: return "The feed CSV contains no cattle ingredients."
            case .invalidHeader: return "The feed CSV has missing or duplicate column names."
            case .malformedCSV: return "The feed CSV contains invalid quoting."
            case .invalidRecord(let record, let reason): return "CSV record \(record): \(reason)"
            }
        }
    }
}
