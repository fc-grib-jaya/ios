import Charts
import SwiftUI

struct ProgressChart: View {
    let records: [CattleWeightProgress]
    @ScaledMetric(relativeTo: .caption) private var labelSpacing = 64.0

    private let axisColor = AppColor.Primitive.Neutral.shade400

    var body: some View {
        let layout = ProgressChartLayout(records: records)
        Group {
            if layout.records.isEmpty {
                Text("Belum ada riwayat pengukuran")
                    .font(AppFont.caption)
                    .foregroundStyle(axisColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                GeometryReader { geometry in
                    chart(layout, width: geometry.size.width)
                }
            }
        }
        .frame(height: 260)
    }

    private func chart(_ layout: ProgressChartLayout, width: CGFloat) -> some View {
        Chart {
            if layout.records.count > 1 {
                ForEach(layout.records, id: \.id) { entry in
                    LineMark(
                        x: .value("Tanggal", entry.measuredAt),
                        y: .value("Bobot", entry.weight)
                    )
                    .interpolationMethod(.monotone)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .foregroundStyle(AppColor.Primitive.Secondary.shade500)
                }
            }

            ForEach(layout.records, id: \.id) { entry in
                PointMark(
                    x: .value("Tanggal", entry.measuredAt),
                    y: .value("Bobot", entry.weight)
                )
                .symbol {
                    measurementSymbol(isLatest: entry.id == layout.records.last?.id)
                }
                .accessibilityLabel(
                    entry.measuredAt.formatted(.dateTime.day().month(.wide).year().locale(Locale(identifier: "id_ID")))
                )
                .accessibilityValue("\(entry.weight.formatted()) kg")
            }
        }
        .chartXScale(domain: layout.xDomain)
        .chartYScale(domain: layout.yDomain)
        .chartLegend(.hidden)
        .chartXAxis {
            AxisMarks(values: layout.labelDates(width: width, minimumSpacing: labelSpacing)) { value in
                AxisTick()
                    .foregroundStyle(axisColor)
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        VStack(spacing: AppSpacing.xxxs) {
                            Text(date.formatted(.dateTime.day().month(.abbreviated).locale(Locale(identifier: "id_ID"))))
                            Text(date.formatted(.dateTime.year().locale(Locale(identifier: "id_ID"))))
                        }
                        .font(AppFont.caption)
                        .foregroundStyle(axisColor)
                        .fixedSize()
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(axisColor)
                AxisTick()
                    .foregroundStyle(axisColor)
                AxisValueLabel {
                    if let weight = value.as(Double.self) {
                        Text("\(weight.formatted(.number.precision(.fractionLength(0...1)))) kg")
                            .font(AppFont.caption)
                            .foregroundStyle(axisColor)
                    }
                }
            }
        }
        .chartPlotStyle { plot in
            plot.background {
                GeometryReader { geometry in
                    Path { path in
                        path.move(to: .zero)
                        path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    }
                    .stroke(axisColor, lineWidth: 1)
                }
            }
        }
        .padding(.top, AppSpacing.xs)
    }

    private func measurementSymbol(isLatest: Bool) -> some View {
        Circle()
            .fill(isLatest
                ? AppColor.Primitive.Secondary.shade950
                : AppColor.Primitive.Secondary.shade500)
            .overlay {
                Circle()
                    .strokeBorder(AppColor.Primitive.Base.white, lineWidth: isLatest ? 4 : 2)
            }
            .frame(width: isLatest ? 16 : 12, height: isLatest ? 16 : 12)
            .shadow(
                color: AppColor.Primitive.Secondary.shade500.opacity(isLatest ? 0.6 : 0),
                radius: 4
            )
    }
}

/// Presentation calculations only; the existing progress model remains the data source.
private struct ProgressChartLayout {
    let records: [CattleWeightProgress]

    init(records: [CattleWeightProgress]) {
        self.records = CattleWeightProgressViewModel.sortedProgress(
            records.filter { $0.weight.isFinite && $0.measuredAt.timeIntervalSinceReferenceDate.isFinite }
        )
    }

    var xDomain: ClosedRange<Date> {
        let first = records.first?.measuredAt ?? .now
        let last = records.last?.measuredAt ?? first
        let span = last.timeIntervalSince(first)
        // A single date (including coincident records) stays at the horizontal center.
        let padding = span > 0 ? span * 0.2 : 86_400
        return first.addingTimeInterval(-padding)...last.addingTimeInterval(padding)
    }

    var yDomain: ClosedRange<Double> {
        let minimum = records.map(\.weight).min() ?? 0
        let maximum = records.map(\.weight).max() ?? minimum
        let padding = max(5, (maximum - minimum) * 0.2)
        return (minimum - padding)...(maximum + padding)
    }

    func labelDates(width: CGFloat, minimumSpacing: CGFloat) -> [Date] {
        let dates = Array(Set(records.map(\.measuredAt))).sorted()
        guard let latest = dates.last else { return [] }
        // Reserve space for the Y labels, then compare actual temporal positions.
        let plotWidth = max(1, width - 80)
        let duration = xDomain.upperBound.timeIntervalSince(xDomain.lowerBound)
        var selected = [latest]
        var previous = latest
        for date in dates.dropLast().reversed() {
            let distance = previous.timeIntervalSince(date) / duration * plotWidth
            if distance >= minimumSpacing {
                selected.append(date)
                previous = date
            }
        }
        return selected.reversed()
    }
}

private enum ProgressChartPreviewData {
    static func records(weights: [Double]) -> [CattleWeightProgress] {
        let start = Date(timeIntervalSince1970: 1_770_768_000)
        return weights.enumerated().map { index, weight in
            CattleWeightProgress(
                weight: weight,
                measuredAt: start.addingTimeInterval(Double(index * index + index) * 86_400)
            )
        }
    }
}

#Preview("Kosong") {
    ProgressChart(records: []).padding()
}

#Preview("Satu pengukuran") {
    ProgressChart(records: ProgressChartPreviewData.records(weights: [490])).padding()
}

#Preview("Beberapa pengukuran") {
    ProgressChart(records: ProgressChartPreviewData.records(weights: [480, 490, 485, 510, 525]).reversed())
        .padding()
}

#Preview("Bobot sama") {
    ProgressChart(records: ProgressChartPreviewData.records(weights: [490, 490, 490, 490]))
        .padding()
}
