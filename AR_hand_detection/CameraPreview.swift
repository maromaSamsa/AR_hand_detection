//
//  CameraPreview.swift
//  AR_hand_detection
//
//  Created by WTMH on 2021/10/7.
//

import UIKit
import AVFoundation

final class CameraPreview: UIView{
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer{
        layer as! AVCaptureVideoPreviewLayer
    }
    
}
