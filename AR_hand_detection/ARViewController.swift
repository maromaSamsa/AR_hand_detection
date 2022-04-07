//
//  ARViewController.swift
//  AR_hand_detection
//
//  Created by maromasamsa on 2022/3/8.
//

import ARKit
import UIKit
import CoreML
import Vision

// MARK: life cycle
final public class ARViewController: UIViewController{
    
    private let sceneView = ARSCNView()
    private var handView = UIImageView()
    private let handDetector = HandDetector()
    private var currentBuffer: CVPixelBuffer?
    private var handMaskBuffer: CVPixelBuffer?
    private let testCameraView = UIImageView()
    private let testCameraView_base = UIImageView()
    
    override public func loadView() {
        print("load view")
        super.loadView()
        self.view = testCameraView_base
        testCameraView.frame = CGRect(x: 0.0, y: 0.0, width: 814.0, height: 413.999)
        self.view.addSubview(testCameraView)
    }
    
    override public func viewDidLoad() {
        print("view did load")
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.preferredFramesPerSecond = 20
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        print("view will appear")
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the session with the configuration
        sceneView.session.run(configuration)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        print("view will disappear")
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}

// MARK: ARSessionDelegate
extension ARViewController: ARSessionDelegate{
    
    public func session(_: ARSession, didUpdate frame: ARFrame) {
        // We return early if currentBuffer is not nil or the tracking state of camera is not normal
        guard self.currentBuffer == nil, case .normal = frame.camera.trackingState else {
            return
        }
        self.currentBuffer = frame.capturedImage
        startDetection()
        startRendering()
    }
    
    /// Call CoreML hand detection model to start detection
    private func startDetection() -> Void {
        guard let buffer = self.currentBuffer else{
            return
        }
        handDetector.performDetection(inputBuffer: buffer){
            outputBuffer in
            self.handMaskBuffer = outputBuffer
        }
    }
    
    /// still designing, now is only for access hand mask buffer image, turning black pixel to transparent
    private func startRendering() -> Void {
        guard let handBuffer = self.handMaskBuffer else{
            return
        }
        guard let cameraBuffer = self.currentBuffer else{
            return
        }

        defer {
            DispatchQueue.main.async {
                let ci = CIImage(cvPixelBuffer: cameraBuffer)
                let ui = UIImage(ciImage: ci)
                self.testCameraView.image = ui
                self.testCameraView.transform = CGAffineTransform.identity.scaledBy(x: -1, y: 1)
                self.handView.image = UIImage(pixelBuffer: handBuffer)
                self.handView.transform = CGAffineTransform.identity.rotated(by: -.pi/2)
                self.handView.frame = self.testCameraView.bounds
                self.testCameraView.mask = self.handView
                print("subview f&b", self.testCameraView.frame, self.testCameraView.bounds)
                self.testCameraView_base.image = ui
                self.testCameraView_base.transform = CGAffineTransform.identity.rotated(by: .pi/2)
                print("view f&b", self.testCameraView_base.frame, self.testCameraView_base.bounds)
                self.handMaskBuffer = nil
                self.currentBuffer = nil
            }
        }
        
        // You must call the CVPixelBufferLockBaseAddress(_:_:) function before accessing pixel data
        CVPixelBufferLockBaseAddress(
            handBuffer, CVPixelBufferLockFlags(rawValue: 0)
        )

        if CVPixelBufferGetBaseAddress(handBuffer) != nil {
            // this pointer offset is count as size of byte
            let ptr = unsafeBitCast(CVPixelBufferGetBaseAddress(handBuffer), to: UnsafeMutablePointer<UInt8>.self)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(handBuffer)
            let size = (
                height: CVPixelBufferGetHeight(handBuffer),
                width: CVPixelBufferGetWidth(handBuffer)
            )
            
            // in debug mode, use "stride" is more effient than using "for" loop
            for y in stride(from: 0, to: size.height, by: 1){
                for x in stride(from: 0, to: size.width, by: 1){
                    let offset = bytesPerRow * y + (bytesPerRow/size.width) * x
                    if ptr[offset] == 0{
                        ptr[offset + 3] = 0 // alpha
                    }
//                    ptr[offset + 0] = 0 // b
//                    ptr[offset + 1] = 0 // g
//                    ptr[offset + 2] = 0 // r
//                    ptr[offset + 3] = 0 // alpha
                }
            }

        }
        CVPixelBufferUnlockBaseAddress(
            handBuffer, CVPixelBufferLockFlags(rawValue: 0)
        )
        
    }
    
}

extension ARViewController: ARSCNViewDelegate{

}



