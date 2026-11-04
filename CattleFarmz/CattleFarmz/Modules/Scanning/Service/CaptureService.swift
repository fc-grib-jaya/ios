import ARKit
import AVFoundation
import CoreImage
import Observation
import RealityKit
import SwiftUI

// The AR frame is retained only while capture buffers are copied. No mesh fusion:
// moving cattle must not be accumulated across different timestamps.
@Observable
final class CaptureService: NSObject, ARSessionDelegate {
    @ObservationIgnored let session = ARSession()
    var status="Menyiapkan kamera…"
    var ready=false
    var busy=false
    
    @ObservationIgnored private var running=false
    @ObservationIgnored private var startRequest=0
    @ObservationIgnored private let processing=DispatchQueue(label:"capture.snapshot",qos:.userInitiated)
    @ObservationIgnored private let context=CIContext()
    
    override init() {
        super.init()
        session.delegate=self
    }
    
    func start() {
        guard !running else {return}
        startRequest += 1
        let request=startRequest
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) else {
            status="Pengukuran ini membutuhkan perangkat dengan LiDAR."; return
        }
        AVCaptureDevice.requestAccess(for:.video) { granted in
            DispatchQueue.main.async {
                guard request == self.startRequest else {return}
                guard granted else {self.status="Izin kamera diperlukan. Aktifkan melalui Settings.";return}
                let config=ARWorldTrackingConfiguration()
                config.frameSemantics = ARWorldTrackingConfiguration.supportsFrameSemantics([.sceneDepth, .smoothedSceneDepth])
                    ? [.sceneDepth, .smoothedSceneDepth] : [.sceneDepth]
                self.running=true
                self.session.run(config,options:[.resetTracking,.removeExistingAnchors])
                self.status="Arahkan ke satu sisi tubuh. Tunggu depth siap."
            }
        }
    }
    
    func stop() {
        startRequest += 1
        running=false
        session.pause()
        ready=false
    }
    
    func session(_ session:ARSession,didUpdate frame:ARFrame) {
        let ok=frame.sceneDepth != nil
        DispatchQueue.main.async {
            guard self.running else {return}
            if self.ready != ok {self.ready=ok}
            if ok && !self.busy { self.status="LiDAR siap · ambil dari posisi aman" } }
    }
    
    func session(_ session:ARSession,didFailWithError error:Error) {
        DispatchQueue.main.async {self.running=false;self.ready=false;self.status=error.localizedDescription}
    }
    func sessionWasInterrupted(_ session:ARSession) { DispatchQueue.main.async {self.ready=false;self.status="Kamera terjeda."} }
    func sessionInterruptionEnded(_ session:ARSession) { DispatchQueue.main.async {if self.running {self.stop();self.start()}} }
    
    func capture(viewportSize: CGSize, completion:@escaping(Result<Capture,Error>)->Void) {
        guard !busy,let frame=session.currentFrame,let scene=frame.sceneDepth else {
            completion(.failure(AppFailure.message("Depth belum siap. Tunggu lalu ambil ulang.")));return
        }
        busy=true
        processing.async {
            let outcome:Result<Capture,Error> = Result {
                // Both image and depth are taken from this exact ARFrame.
                let ci=CIImage(cvPixelBuffer:frame.capturedImage).oriented(.right)
                guard let cg=self.context.createCGImage(ci,from:ci.extent) else {throw AppFailure.message("Foto gagal dibuat.")}
                let image=cg
                let k=frame.camera.intrinsics,res=frame.camera.imageResolution
                let calibration=CameraCalibration(fx:Double(k[0][0]),fy:Double(k[1][1]),cx:Double(k[2][0]),cy:Double(k[2][1]),width:Int(res.width),height:Int(res.height))
                let depth=try self.copyDepth(scene,calibration:calibration)
                let smoothedDepth=frame.smoothedSceneDepth.flatMap {
                    try? self.copyDepth($0,calibration:calibration)
                }
                let crop = ImageCrop.matchingPreview(
                    imageSize: CGSize(width: cg.width, height: cg.height),
                    viewportSize: viewportSize
                )
                let metadata=CaptureMetadata(date:Date(),depth:depth,smoothedDepth:smoothedDepth,previewCrop:crop)
                return Capture(image:image,metadata:metadata)
            }
            DispatchQueue.main.async {self.busy=false;completion(outcome)}
        }
    }
    private func copyDepth(_ scene:ARDepthData,calibration:CameraCalibration) throws -> DepthFrame {
        let buffer=scene.depthMap
        CVPixelBufferLockBaseAddress(buffer,.readOnly)
        defer {CVPixelBufferUnlockBaseAddress(buffer,.readOnly)}
        let w=CVPixelBufferGetWidth(buffer),h=CVPixelBufferGetHeight(buffer)
        guard let base=CVPixelBufferGetBaseAddress(buffer),w>0,h>0 else {throw MeasurementError.invalidDepth}
        var meters=[Float](repeating:0,count:w*h)
        for y in 0..<h {
            let row=base.advanced(by:y*CVPixelBufferGetBytesPerRow(buffer)).assumingMemoryBound(to:Float.self)
            for x in 0..<w {
                let z=row[x]
                meters[y*w+x]=z.isFinite && z>0 ? z : 0
            }
        }
        var confidence=[UInt8](repeating:0,count:w*h)
        if let map=scene.confidenceMap,CVPixelBufferGetWidth(map)==w,CVPixelBufferGetHeight(map)==h {
            CVPixelBufferLockBaseAddress(map,.readOnly)
            defer {CVPixelBufferUnlockBaseAddress(map,.readOnly)}
            if let address=CVPixelBufferGetBaseAddress(map) {
                for y in 0..<h {
                    let row=address.advanced(by:y*CVPixelBufferGetBytesPerRow(map)).assumingMemoryBound(to:UInt8.self)
                    for x in 0..<w {confidence[y*w+x]=row[x]}
                }
            }
        }
        return DepthFrame(width:w,height:h,meters:meters,confidence:confidence,calibration:calibration)
    }
}
struct CameraPreview: UIViewRepresentable {
    let service:CaptureService
    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        view.session = service.session
        return view
    }
    func updateUIView(_ view: ARView, context: Context) {}
}
