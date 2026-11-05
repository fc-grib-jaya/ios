//
//  CaptureService.swift
//  CattleFarmz
//

import ARKit
import AVFoundation
import CoreImage
import Observation
import UIKit

/// Live `ScanCapturing` backed by an `ARSession` plus the LiDAR depth map.
///
/// Nothing is allocated until the user opens the camera: the `ARSession` is
/// created on first access and the `CIContext` on the first capture. `stop()`
/// pauses the session and drops the Core Image context, so an idle app holds
/// no AR or rendering resources.
///
/// The AR frame is retained only while capture buffers are copied. No mesh
/// fusion: moving cattle must not be accumulated across different timestamps.
@Observable
@MainActor
final class CaptureService: NSObject, ARSessionDelegate, ScanCapturing {
    private(set) var status = "Menyiapkan kamera…"
    private(set) var isReady = false
    private(set) var isBusy = false

    /// Created on first access; the camera preview needs it, so reading this
    /// is what allocates the session.
    var session: ARSession? {
        if let sessionStorage { return sessionStorage }
        let session = ARSession()
        session.delegate = self
        sessionStorage = session
        return session
    }

    @ObservationIgnored private var sessionStorage: ARSession?
    @ObservationIgnored private var running = false
    @ObservationIgnored private var startRequest = 0
    @ObservationIgnored private let processing = DispatchQueue(
        label: "capture.snapshot",
        qos: .userInitiated
    )
    @ObservationIgnored private var context: CIContext?

    func start() {
        guard !running else { return }
        startRequest += 1
        let request = startRequest
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) else {
            status = "Pengukuran ini membutuhkan perangkat dengan LiDAR."
            return
        }
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                guard request == self.startRequest else { return }
                guard granted else {
                    self.status = "Izin kamera diperlukan. Aktifkan melalui Settings."
                    return
                }
                let config = ARWorldTrackingConfiguration()
                config.frameSemantics = ARWorldTrackingConfiguration
                    .supportsFrameSemantics([.sceneDepth, .smoothedSceneDepth])
                    ? [.sceneDepth, .smoothedSceneDepth]
                    : [.sceneDepth]
                self.running = true
                self.session?.run(config, options: [.resetTracking, .removeExistingAnchors])
                self.status = "Arahkan ke satu sisi tubuh. Tunggu depth siap."
            }
        }
    }

    func stop() {
        startRequest += 1
        running = false
        sessionStorage?.pause()
        context = nil
        isReady = false
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let depthAvailable = frame.sceneDepth != nil
        DispatchQueue.main.async {
            guard self.running else { return }
            if self.isReady != depthAvailable { self.isReady = depthAvailable }
            if depthAvailable && !self.isBusy {
                self.status = "LiDAR siap · ambil dari posisi aman"
            }
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.running = false
            self.isReady = false
            self.status = error.localizedDescription
        }
    }

    func sessionWasInterrupted(_ session: ARSession) {
        DispatchQueue.main.async {
            self.isReady = false
            self.status = "Kamera terjeda."
        }
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        DispatchQueue.main.async {
            if self.running {
                self.stop()
                self.start()
            }
        }
    }

    func capture(
        viewportSize: CGSize,
        completion: @escaping (Result<Capture, Error>) -> Void
    ) {
        guard !isBusy, let frame = sessionStorage?.currentFrame, let scene = frame.sceneDepth else {
            completion(.failure(AppFailure.message("Depth belum siap. Tunggu lalu ambil ulang.")))
            return
        }
        isBusy = true
        let context = self.context ?? CIContext()
        self.context = context
        let orientation = Self.displayOrientation()
        processing.async {
            let outcome: Result<Capture, Error> = Result {
                // Both image and depth are taken from this exact ARFrame and
                // rotated for the interface orientation that is on screen.
                let ci = CIImage(cvPixelBuffer: frame.capturedImage)
                    .oriented(orientation.exifOrientation)
                guard let image = context.createCGImage(ci, from: ci.extent) else {
                    throw AppFailure.message("Foto gagal dibuat.")
                }
                let intrinsics = frame.camera.intrinsics
                let resolution = frame.camera.imageResolution
                let calibration = CameraCalibration(
                    fx: Double(intrinsics[0][0]),
                    fy: Double(intrinsics[1][1]),
                    cx: Double(intrinsics[2][0]),
                    cy: Double(intrinsics[2][1]),
                    width: Int(resolution.width),
                    height: Int(resolution.height)
                )
                let depth = try Self.copyDepth(
                    scene,
                    calibration: calibration,
                    orientation: orientation
                )
                let smoothedDepth = frame.smoothedSceneDepth.flatMap {
                    try? Self.copyDepth(
                        $0,
                        calibration: calibration,
                        orientation: orientation
                    )
                }
                let crop = ImageCrop.matchingPreview(
                    imageSize: CGSize(width: image.width, height: image.height),
                    viewportSize: viewportSize
                )
                return Capture(
                    image: image,
                    metadata: CaptureMetadata(
                        date: Date(),
                        depth: depth,
                        smoothedDepth: smoothedDepth,
                        previewCrop: crop
                    )
                )
            }
            DispatchQueue.main.async {
                self.isBusy = false
                completion(outcome)
            }
        }
    }

    /// Interface orientation of the scene showing the camera.
    private static func displayOrientation() -> CaptureOrientation {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
        let orientation = (scenes.first { $0.activationState == .foregroundActive }
            ?? scenes.first)?.effectiveGeometry.interfaceOrientation
        switch orientation {
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        case .portraitUpsideDown: return .portraitUpsideDown
        default: return .portrait
        }
    }

    /// Copies the depth and confidence buffers before ARKit recycles them.
    /// Nonisolated: runs on the capture queue, not the main actor.
    nonisolated private static func copyDepth(
        _ scene: ARDepthData,
        calibration: CameraCalibration,
        orientation: CaptureOrientation
    ) throws -> DepthFrame {
        let buffer = scene.depthMap
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        let width = CVPixelBufferGetWidth(buffer)
        let height = CVPixelBufferGetHeight(buffer)
        guard let base = CVPixelBufferGetBaseAddress(buffer), width > 0, height > 0 else {
            throw MeasurementError.invalidDepth
        }
        var meters = [Float](repeating: 0, count: width * height)
        for y in 0..<height {
            let row = base
                .advanced(by: y * CVPixelBufferGetBytesPerRow(buffer))
                .assumingMemoryBound(to: Float.self)
            for x in 0..<width {
                let z = row[x]
                meters[y * width + x] = z.isFinite && z > 0 ? z : 0
            }
        }
        var confidence = [UInt8](repeating: 0, count: width * height)
        if let map = scene.confidenceMap,
           CVPixelBufferGetWidth(map) == width,
           CVPixelBufferGetHeight(map) == height {
            CVPixelBufferLockBaseAddress(map, .readOnly)
            defer { CVPixelBufferUnlockBaseAddress(map, .readOnly) }
            if let address = CVPixelBufferGetBaseAddress(map) {
                for y in 0..<height {
                    let row = address
                        .advanced(by: y * CVPixelBufferGetBytesPerRow(map))
                        .assumingMemoryBound(to: UInt8.self)
                    for x in 0..<width { confidence[y * width + x] = row[x] }
                }
            }
        }
        return DepthFrame(
            width: width,
            height: height,
            meters: meters,
            confidence: confidence,
            calibration: calibration,
            orientation: orientation
        )
    }
}
