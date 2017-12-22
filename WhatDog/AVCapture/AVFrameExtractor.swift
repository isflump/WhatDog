//
//  AVFrameExtractor.swift
//  WhatDog
//
//  Created by Ryan Yan on 12/21/17.
//

import UIKit
import AVFoundation

protocol AVFrameExtractorDelegate: class {
    func captured(image: UIImage)
}

class AVFrameExtractor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate{
    
    var captureTokenTimer: Timer?
    private var captureToken = true
    private var permissionGranted = false
    let captureSession = AVCaptureSession()
    private let context = CIContext()
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    private var selectCaptureDevice: AVCaptureDevice? {
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: position)
    }
    
    private let position = AVCaptureDevice.Position.back
    private let quality = AVCaptureSession.Preset.medium
    
    weak var delegate: AVFrameExtractorDelegate?
    
    override init() {
        super.init()
        sessionQueue.async { [unowned self] in
            self.setupCamera()
            self.captureSession.startRunning()
        }
        self.captureTokenTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.enableCaptureToken()
        }
    }
    
    private func setupCamera(){
        checkPermission()
        guard let captureDevice = selectCaptureDevice else { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        guard captureSession.canAddInput(captureDeviceInput) else { return }
        
        captureSession.sessionPreset = quality
        captureSession.addInput(captureDeviceInput)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        
        guard let connection = videoOutput.connection(with: AVFoundation.AVMediaType.video) else { return }
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = .portrait
        connection.isVideoMirrored = position == .front
    }
    
    private func checkPermission(){
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [unowned self] granted in
            self.permissionGranted = granted
        }
    }
    
    private func enableCaptureToken(){
        captureToken = true
    }
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        if captureToken{
            captureToken = false
            guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
            DispatchQueue.main.async { [unowned self] in
                self.delegate?.captured(image: uiImage)
            }
        }
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
