import Foundation

struct MeasurementGuideStep: Identifiable {
    let id: String
    let label: String
    let title: String
    let instruction: String
    let number: Int

    static let steps: [MeasurementGuideStep] = [
                .init(id: "Chest",
                      label: "Dada",
                      title: "Tandai Bagian Dada",
                      instruction: "Ketuk Dada di dekat pangkal kaki depan, sisi menghadap kamera",
                      number: 1),
                .init(id: "pin",
                      label: "Pangkal Ekor",
                      title: "Tandai Bagian Pangkal Ekor",
                      instruction: "Ketuk tonjolan tulang duduk di bagian belakang panggul. Dua titik ini membentuk panjang badan.",
                      number: 2),
                .init(id: "chestTop",
                      label: "Punuk",
                      title: "Tandai Bagian Punuk",
                      instruction: "Cari garis tepat di belakang kaki ketuk tepi atas punuk",
                      number: 3),
                .init(id: "chestBottom",
                      label: "Ketiak",
                      title: "Tandai Bagian Ketiak",
                      instruction: "Ketuk tepi ketiak. Garis menghubungkan Lingkar dada",
                      number: 4)
            ]
}
