import Charts
import SwiftUI

struct ProteinContributionCard: View {
    let result: RationCalculationResult
    @Environment(\.dynamicTypeSize) private var textSize
    private let colors = [AppColor.Primitive.Primary.shade300, AppColor.Primitive.Primary.shade500, AppColor.Primitive.Primary.shade100, AppColor.Primitive.Primary.shade700]
    private var total: Double { result.proteinKilogramsPerAnimalPerDay }

    var body: some View {
        let items = result.items.filter { $0.proteinKilogramsPerAnimalPerDay > 0 }
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Kontribusi protein setiap bahan").font(AppFont.title)
            if items.isEmpty {
                Text("Belum ada kontribusi protein.").font(AppFont.body)
            } else {
                let callouts = items.count <= 3 && !textSize.isAccessibilitySize
                Chart(Array(items.enumerated()), id: \.element.id) { index, item in
                    SectorMark(angle: .value("Protein (kg)", item.proteinKilogramsPerAnimalPerDay),
                               innerRadius: .ratio(0.60), outerRadius: .ratio(callouts ? 0.68 : 0.9))
                        .foregroundStyle(colors[index % colors.count])
                        .accessibilityLabel(item.ingredient.name)
                        .accessibilityValue(detail(item))
                }
                .chartOverlay { _ in
                    GeometryReader { geometry in
                        let w = geometry.size.width
                        let h = geometry.size.height
                        VStack(spacing: AppSpacing.xxs) {
                            Text("Total protein").font(AppFont.headline)
                            Text(mass(total) + " kg/hari").font(AppFont.caption)
                        }
                        .position(x: w / 2, y: h / 2)
                        if callouts {
                            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                                let before = items.prefix(index).reduce(0) { $0 + $1.proteinKilogramsPerAnimalPerDay }
                                let angle = (before + item.proteinKilogramsPerAnimalPerDay / 2) / total * 2 * Double.pi
                                let radius = min(w, h) * 0.34
                                let x = sin(angle)
                                let y = -cos(angle)
                                let labelX = min(max(w / 2 + x * (radius + 45), 51), w - 51)
                                let labelY = min(max(h / 2 + y * (radius + 50), 22), h - 22)
                                Path { path in
                                    path.move(to: CGPoint(x: w / 2 + x * radius, y: h / 2 + y * radius))
                                    path.addLine(to: CGPoint(x: labelX, y: labelY))
                                }.stroke(AppColor.Border.default, lineWidth: 1)
                                VStack(spacing: 0) {
                                    Text(item.ingredient.name)
                                    Text(detail(item))
                                }
                                .font(AppFont.caption)
                                .padding(AppSpacing.xxs)
                                .frame(maxWidth: 102)
                                .background(AppColor.Primitive.Secondary.shade50, in: RoundedRectangle(cornerRadius: AppRadius.small))
                                .position(x: labelX, y: labelY)
                            }
                        }
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                if !callouts {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        LabeledContent {
                            Text(detail(item))
                        } label: {
                            Label { Text(item.ingredient.name) } icon: {
                                Circle().fill(colors[index % colors.count]).frame(width: AppSpacing.xs, height: AppSpacing.xs)
                            }
                        }.font(AppFont.caption)
                    }
                }
            }
        }
        .evaluationCard()
    }

    private func mass(_ value: Double) -> String {
        value.formatted(.number.locale(Locale(identifier: "id_ID")).precision(.fractionLength(3)))
    }

    private func detail(_ item: RationItem) -> String {
        let value = item.proteinKilogramsPerAnimalPerDay
        return evaluationNumber(value / total * 100, digits: 0) + "% · " + mass(value) + " kg"
    }
}

#if DEBUG
#Preview {
    ProteinContributionCard(result: RationEvaluationPreviewData.result).padding(AppSpacing.md)
}
#endif
