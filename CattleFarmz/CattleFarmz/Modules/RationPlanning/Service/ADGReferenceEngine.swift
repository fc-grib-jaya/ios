import Foundation

/// Looks up the defaults supplied for this app. It does not predict gain from a ration.
enum ADGReferenceEngine {
    static func reference(
        breedName: String,
        sex: CattleSex,
        stage: CattleProductionStage
    ) -> ADGReference? {
        let name = breedName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let kilograms: Double?
        let note: String
        let source: String

        switch name {
        case "bali":
            kilograms = 0.6
            note = "Usulan awal dari tabel aplikasi. Percobaan Kementan mencatat 0,30–0,61 kg/hari pada perlakuan pakan tertentu."
            source = "https://ppid.pertanian.go.id/doc/127/Lap.Tahunan%20TA.2021.pdf"
        case "madura":
            kilograms = 0.5
            note = "Usulan awal dari tabel aplikasi. Percobaan Kementan mencatat 0,32–0,53 kg/hari pada perlakuan pakan tertentu."
            source = "https://ppid.pertanian.go.id/doc/127/Lap.Tahunan%20TA.2021.pdf"
        case "limousin", "simmental":
            kilograms = 1.0
            note = "Usulan awal dari tabel aplikasi, dibuat lebih rendah dari kelompok ADG 1,2–1,5 kg/hari pada studi jantan di Eropa. Belum dikalibrasi untuk kondisi Indonesia."
            source = "https://www.sciencedirect.com/science/article/abs/pii/S1871141307003162"
        case "brahman":
            kilograms = 0.9
            note = "Usulan sementara. Dasarnya penelitian Brahman Cross dengan ADG 0,85–1,25 kg/hari. Penerapan pada Brahman murni belum tervalidasi."
            source = "https://journal.ugm.ac.id/buletinpeternakan/article/download/1408/1206"
        case "peranakan ongole":
            kilograms = 0.7
            note = "Usulan awal dari tabel aplikasi, dibuat lebih rendah dari ADG sekitar 0,80–0,90 kg/hari pada penelitian penggemukan berbasis sorgum."
            source = "https://journal.ipb.ac.id/ipthp/article/download/15544/11448/46356"
        case "friesian holstein":
            if sex == .male {
                kilograms = 0.9
                note = "Usulan awal untuk jantan. Dasarnya penelitian PFH jantan dengan ADG sekitar 0,95–0,99 kg/hari; penerapan pada FH murni perlu ditinjau."
                source = "https://ejournal.uby.ac.id/index.php/tas/article/download/1203/482/5451"
            } else if stage == .heifer {
                kilograms = 0.8
                note = "Usulan awal khusus dara betina sebelum pubertas. Panduan menyebut sekitar 0,73–0,86 kg/hari. Belum ditetapkan untuk betina laktasi, bunting, atau dewasa."
                source = "https://extension.psu.edu/monitoring-dairy-heifer-growth"
            } else {
                kilograms = nil
                note = "Acuan 0,8 kg/hari pada tabel hanya untuk dara betina sebelum pubertas. Profil ini belum menggunakan fase dara, sehingga target diisi manual."
                source = "https://extension.psu.edu/monitoring-dairy-heifer-growth"
            }
        case "aceh":
            kilograms = 0.5
            note = "Usulan awal dari tabel aplikasi. Dasarnya penelitian jantan usia 2–2,5 tahun dengan ADG 0,47–0,65 kg/hari."
            source = "https://jurnal.usk.ac.id/agripet/article/download/819/757"
        default:
            return nil
        }
        return ADGReference(
            kilogramsPerDay: kilograms,
            note: note + " Sesuaikan dengan kondisi sapi dan evaluasi pertumbuhan aktual.",
            sources: [URL(string: source)!]
        )
    }
}
