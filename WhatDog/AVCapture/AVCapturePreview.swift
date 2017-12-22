//
//  AVCapturePreview.swift
//  WhatDog
//
//  Created by Ryan Yan on 12/21/17.
//

import UIKit
import AVFoundation

class AVCapturePreview: UIView {
    
    override class var layerClass : AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer? {
        guard let previewlayer = layer as? AVCaptureVideoPreviewLayer else{
            return nil
        }
        return previewlayer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer?.session
        }
        set {
            videoPreviewLayer?.session = newValue
        }
    }
}
