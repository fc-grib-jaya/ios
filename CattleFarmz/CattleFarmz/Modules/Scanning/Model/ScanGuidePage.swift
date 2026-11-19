import Foundation

/// Camera help pages, independent of the actual four-point measurement flow.
struct ScanGuidePage: Identifiable {
    let id: String
    let title: String
    let instruction: String
    let imageName: String

    static let pages: [ScanGuidePage] = {
        let images = [
            "Chest": "Dada",
            "shoulder": "Dada",
            "pin": "PangkalEkor",
            "chestTop": "Punuk",
            "chestBottom": "Ketiak"
        ]
        return [
            ScanGuidePage(
                id: "sidePhoto",
                title: "Foto sapi dari samping",
                instruction: "Pastikan seluruh tubuh sapi terlihat dari samping dan pengambilan foto simetris.",
                imageName: "SapiSamping"
            )
        ] + MeasurementGuideStep.steps.map { step in
            ScanGuidePage(
                id: step.id,
                title: step.title,
                instruction: step.instruction,
                imageName: images[step.id] ?? "SapiSamping"
            )
        }
    }()
}
