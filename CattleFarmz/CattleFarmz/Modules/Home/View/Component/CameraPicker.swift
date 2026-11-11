//
//  CameraPicker.swift
//  CattleFarmz
//

import AVFoundation
import SwiftUI
import UIKit

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController()
        viewController.onFinish = { image in
            context.coordinator.parent.image = image
            context.coordinator.parent.isPresented = false
        }
        viewController.onCancel = {
            context.coordinator.parent.isPresented = false
        }
        return viewController
    }

    func updateUIViewController(
        _ uiViewController: CameraViewController,
        context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator {
        var parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }
    }
}

final class CameraViewController: UIViewController {
    var onFinish: ((UIImage?) -> Void)?
    var onCancel: (() -> Void)?

    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private let overlayView = UIView()
    private let cropOverlay = CAShapeLayer()
    private let capturedImageView = UIImageView()
    private let captureButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let retakeButton = UIButton(type: .system)
    private let usePhotoButton = UIButton(type: .system)

    private var imageScale: CGFloat = 1
    private var imageOffset: CGPoint = .zero
    private var initialPinchScale: CGFloat = 1
    private var initialPanOffset: CGPoint = .zero
    private var cropRect: CGRect = .zero
    

    private var capturedImage: UIImage?
    private var isShowingCapturedImage = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureCamera()
        configureControls()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !isShowingCapturedImage else { return }
        startSessionIfAuthorized()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        session.stopRunning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        previewLayer.frame = view.bounds
        capturedImageView.frame = view.bounds
        overlayView.frame = view.bounds
        cropOverlay.frame = overlayView.bounds
        updateCropOverlay()
        layoutControls()
//        cropOverlay.frame = view.bounds
//        updateCropOverlay()
//        layoutControls()
    }

    private func configureCamera() {
//        previewLayer.videoGravity = .resizeAspectFill
//        view.layer.insertSublayer(previewLayer, at: 0)
//        view.layer.addSublayer(cropOverlay)

//        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        overlayView.isUserInteractionEnabled = false
        overlayView.backgroundColor = .clear
        overlayView.isHidden = true
        view.addSubview(overlayView)
        overlayView.layer.addSublayer(cropOverlay)
        cropOverlay.isHidden = true
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input),
              session.canAddOutput(photoOutput) else {
            return
        }

        session.beginConfiguration()
        session.sessionPreset = .photo
        session.addInput(input)
        session.addOutput(photoOutput)
        session.commitConfiguration()
        previewLayer.session = session
    }

    private func configureControls() {
        configureButton(cancelButton, title: "Cancel", action: #selector(cancelCamera))
        configureButton(captureButton, title: "", action: #selector(capturePhoto))
        configureButton(retakeButton, title: "Retake", action: #selector(retakePhoto))
        configureButton(usePhotoButton, title: "Use Photo", action: #selector(usePhoto))

        captureButton.layer.cornerRadius = 35
        captureButton.backgroundColor = .white
        captureButton.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        captureButton.layer.borderWidth = 6

        retakeButton.isHidden = true
        usePhotoButton.isHidden = true
    }

    private func configureButton(
        _ button: UIButton,
        title: String,
        action: Selector
    ) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.addTarget(self, action: action, for: .touchUpInside)
        view.addSubview(button)
    }

    private func layoutControls() {
        let safeArea = view.safeAreaInsets
        cancelButton.frame = CGRect(x: 20, y: safeArea.top + 12, width: 100, height: 44)
        captureButton.frame = CGRect(
            x: (view.bounds.width - 70) / 2,
            y: view.bounds.height - safeArea.bottom - 90,
            width: 70,
            height: 70
        )

        let actionWidth = (view.bounds.width - 60) / 2
        retakeButton.frame = CGRect(
            x: 20,
            y: view.bounds.height - safeArea.bottom - 70,
            width: actionWidth,
            height: 50
        )
        usePhotoButton.frame = CGRect(
            x: 40 + actionWidth,
            y: view.bounds.height - safeArea.bottom - 70,
            width: actionWidth,
            height: 50
        )
    }

    private func updateCropOverlay() {
        let side = min(view.bounds.width - 40, view.bounds.height - 240)
        cropRect = CGRect(
            x: (view.bounds.width - side) / 2,
            y: (view.bounds.height - side) / 2,
            width: side,
            height: side
        )

        let path = UIBezierPath(rect: cropRect)
        cropOverlay.path = path.cgPath
        cropOverlay.fillColor = UIColor.clear.cgColor
        cropOverlay.strokeColor = UIColor.white.cgColor
        cropOverlay.lineWidth = 2
    }

    private func startSessionIfAuthorized() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            if !session.isRunning {
                session.startRunning()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    DispatchQueue.main.async {
                        self?.onCancel?()
                    }
                    return
                }

                DispatchQueue.main.async {
                    self?.session.startRunning()
                }
            }
        default:
            onCancel?()
        }
    }

    @objc private func capturePhoto() {
        photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }

    @objc private func cancelCamera() {
        onCancel?()
    }

    @objc private func retakePhoto() {
        capturedImage = nil
        isShowingCapturedImage = false
        imageScale = 1
        imageOffset = .zero
        capturedImageView.transform = .identity
        capturedImageView.removeFromSuperview()
        overlayView.isUserInteractionEnabled = false
        overlayView.isHidden = true
        cropOverlay.isHidden = true
        retakeButton.isHidden = true
        usePhotoButton.isHidden = true
        captureButton.isHidden = false
        startSessionIfAuthorized()
    }

    @objc private func usePhoto() {
        guard let capturedImage,
              let croppedImage = croppedImage(from: capturedImage) else {
            return
        }

        onFinish?(croppedImage)
    }

    private func showCapturedImage(_ image: UIImage) {
        capturedImage = image.normalized()
        isShowingCapturedImage = true
        session.stopRunning()
        imageScale = 1
        imageOffset = .zero
        capturedImageView.transform = .identity

        capturedImageView.image = capturedImage
        capturedImageView.contentMode = .scaleAspectFill
        capturedImageView.clipsToBounds = true
        capturedImageView.frame = view.bounds
        capturedImageView.isUserInteractionEnabled = true

        if capturedImageView.superview == nil {
            view.addSubview(capturedImageView)
        }

        configureCropOverlay()
        configureCropGestures()
        cropOverlay.isHidden = false

        captureButton.isHidden = true
        overlayView.isHidden = false
        retakeButton.isHidden = false
        usePhotoButton.isHidden = false

        view.bringSubviewToFront(capturedImageView)
        view.bringSubviewToFront(overlayView)
        view.bringSubviewToFront(cancelButton)
        view.bringSubviewToFront(retakeButton)
        view.bringSubviewToFront(usePhotoButton)
    }
    
    private func configureCropOverlay() {
        let side = min(view.bounds.width - 40, view.bounds.height - 240)
        cropRect = CGRect(
            x: (view.bounds.width - side) / 2,
            y: (view.bounds.height - side) / 2,
            width: side,
            height: side
        )

        let path = UIBezierPath(rect: view.bounds)
        path.append(UIBezierPath(rect: cropRect))

        cropOverlay.path = path.cgPath
        cropOverlay.fillRule = .evenOdd
        cropOverlay.fillColor = UIColor.black.withAlphaComponent(0.45).cgColor
        cropOverlay.strokeColor = UIColor.white.cgColor
        cropOverlay.lineWidth = 2
    }
    
    private func croppedImage(from image: UIImage) -> UIImage? {
        let imageSize = image.size
        guard imageSize.width > 0, imageSize.height > 0 else { return nil }

        let baseScale = max(
            view.bounds.width / imageSize.width,
            view.bounds.height / imageSize.height
        )
        let displayScale = baseScale * imageScale
        let displayedSize = CGSize(
            width: imageSize.width * displayScale,
            height: imageSize.height * displayScale
        )
        let imageOrigin = CGPoint(
            x: (view.bounds.width - displayedSize.width) / 2 + imageOffset.x,
            y: (view.bounds.height - displayedSize.height) / 2 + imageOffset.y
        )

        let cropInImage = CGRect(
            x: (cropRect.minX - imageOrigin.x) / displayScale,
            y: (cropRect.minY - imageOrigin.y) / displayScale,
            width: cropRect.width / displayScale,
            height: cropRect.height / displayScale
        ).intersection(CGRect(origin: .zero, size: imageSize))

        guard cropInImage.width > 0, cropInImage.height > 0 else { return nil }

        let renderer = UIGraphicsImageRenderer(size: cropInImage.size)
        return renderer.image { _ in
            image.draw(
                in: CGRect(
                    x: -cropInImage.minX,
                    y: -cropInImage.minY,
                    width: imageSize.width,
                    height: imageSize.height
                )
            )
        }
    }

    private func configureCropGestures() {
        // The overlay is visual only. Gestures belong to the image view so
        // the crop image remains directly draggable and pinchable.
        overlayView.isUserInteractionEnabled = false
        capturedImageView.gestureRecognizers?.forEach {
            capturedImageView.removeGestureRecognizer($0)
        }

        let pinch = UIPinchGestureRecognizer(
            target: self,
            action: #selector(handlePinch(_:))
        )
        let pan = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePan(_:))
        )
        pinch.cancelsTouchesInView = false
        pan.cancelsTouchesInView = false

        capturedImageView.addGestureRecognizer(pinch)
        capturedImageView.addGestureRecognizer(pan)
    }

    private func clampedOffset(_ offset: CGPoint) -> CGPoint {
        guard let image = capturedImage else { return offset }

        let baseScale = max(
            view.bounds.width / image.size.width,
            view.bounds.height / image.size.height
        )
        let displayedWidth = image.size.width * baseScale * imageScale
        let displayedHeight = image.size.height * baseScale * imageScale
        let maxX = max(0, (displayedWidth - cropRect.width) / 2)
        let maxY = max(0, (displayedHeight - cropRect.height) / 2)

        return CGPoint(
            x: min(max(offset.x, -maxX), maxX),
            y: min(max(offset.y, -maxY), maxY)
        )
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            initialPinchScale = imageScale

        case .changed, .ended:
            imageScale = min(max(initialPinchScale * gesture.scale, 1), 5)
            imageOffset = clampedOffset(imageOffset)
            capturedImageView.transform = CGAffineTransform(
                translationX: imageOffset.x,
                y: imageOffset.y
            ).scaledBy(x: imageScale, y: imageScale)

        default:
            break
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: capturedImageView)

        switch gesture.state {
        case .began:
            initialPanOffset = imageOffset

        case .changed, .ended:
            imageOffset = clampedOffset(CGPoint(
                x: initialPanOffset.x + translation.x,
                y: initialPanOffset.y + translation.y
            ))
            capturedImageView.transform = CGAffineTransform(
                translationX: imageOffset.x,
                y: imageOffset.y
            ).scaledBy(x: imageScale, y: imageScale)

        default:
            break
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let image = image.normalized()
                .squareCropped()?
                .resized(maxDimension: 1024) else {
                self?.onFinish?(nil)
                return
            }

            // Isi Bobot uses the same one-tap flow as LiDAR: capture, process,
            // and return the normalized image without an intermediate preview.
            self?.onFinish?(image)
        }
    }
}

private extension UIImage {
    func squareCropped() -> UIImage? {
        let normalizedImage = normalized()
        guard let cgImage = normalizedImage.cgImage else { return nil }

        let side = min(cgImage.width, cgImage.height)
        let cropRect = CGRect(
            x: (cgImage.width - side) / 2,
            y: (cgImage.height - side) / 2,
            width: side,
            height: side
        )

        guard let croppedImage = cgImage.cropping(to: cropRect) else {
            return nil
        }

        return UIImage(cgImage: croppedImage, scale: normalizedImage.scale, orientation: .up)
    }

    func resized(maxDimension: CGFloat) -> UIImage {
        let longestSide = max(size.width, size.height)
        guard longestSide > maxDimension, maxDimension > 0 else { return self }

        let scale = maxDimension / longestSide
        let targetSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    func normalized() -> UIImage {
        guard imageOrientation != .up else { return self }

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
