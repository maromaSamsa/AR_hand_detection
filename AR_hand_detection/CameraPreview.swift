//
//  CameraPreview.swift
//  AR_hand_detection
//
//  Created by WTMH on 2021/10/7.
//


import UIKit
import AVFoundation

/// This class responsible for provide an illustration of camera frame stream, rectangular area on screen.
final class CameraPreview: UIView{
    
    /// The class used to create the view’s Core Animation layer, this method is called only once early in the creation of the view
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    
    /// Use this property as layer reference to access the layer
    ///  - layer: the UIView Core Animation layer used for rendering
    var previewLayer: AVCaptureVideoPreviewLayer{
        layer as! AVCaptureVideoPreviewLayer
    }
    
}
