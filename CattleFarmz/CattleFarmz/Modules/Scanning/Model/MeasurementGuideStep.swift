import Foundation

struct MeasurementGuideStep: Identifiable {
    let id: String
    let label: String
    let title: String
    let instruction: String
    let number: Int

    static let steps: [MeasurementGuideStep] = [
                .init(id: "shoulder", label: "1 · Ujung bahu", title: "Tandai ujung bahu",
                      instruction: "Ketuk ujung bahu di dekat pangkal kaki depan, pada sisi yang menghadap kamera. Cocokkan dengan contoh titik 1.", number: 1),
                .init(id: "pin", label: "2 · Tulang duduk", title: "Tandai ujung belakang badan",
                      instruction: "Ketuk tonjolan tulang duduk di bagian belakang panggul, pada sisi yang sama dengan titik 1. Dua titik ini membentuk panjang badan.", number: 2),
                .init(id: "chestTop", label: "3 · Atas dada", title: "Tandai bagian atas dada",
                      instruction: "Cari garis tepat di belakang kaki depan. Pada garis itu, ketuk tepi atas tubuh di punggung.", number: 3),
                .init(id: "chestBottom", label: "4 · Bawah dada", title: "Tandai bagian bawah dada",
                      instruction: "Pada penampang yang sama dengan titik 3, ketuk tepi bawah dada. Garis kuning menghubungkan dua batas dada.", number: 4)
            ]
}
