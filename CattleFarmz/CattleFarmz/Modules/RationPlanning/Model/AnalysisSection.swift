enum AnalysisSection: String, CaseIterable, Identifiable {
    case adequacy = "Kecukupan"
    case dailyAmount = "Jumlah harian"

    var id: Self { self }
}
