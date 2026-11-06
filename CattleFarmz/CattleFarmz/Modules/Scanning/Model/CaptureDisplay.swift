//
//  CaptureDisplay.swift
//  CattleFarmz
//

/// Which layer the measurement screen shows: photo, depth map, or both.
enum CaptureDisplay: String, CaseIterable, Identifiable {
    case photo = "Foto"
    case depth = "Depth"
    case overlay = "Gabungan"

    var id: String { rawValue }
}
