//
//  ARViewController.swift
//  AR_hand_detection
//
//  Created by maromasamsa on 2022/3/8.
//

import ARKit
import CoreML
import Vision

// MARK: life cycle
final public class ARViewController: UIViewController{
    
    private let sceneView = ARSCNView()
    private var handView = UIImageView()
    private let handDetector = HandDetector()
    private var currentBuffer: CVPixelBuffer?
    private var handMaskBuffer: CVPixelBuffer?
    
    override public func loadView() {
        print("load view")
        super.loadView()
        handView.contentMode = .topLeft
        sceneView.mask = handView
        self.view = sceneView
        //self.handView.contentMode = .topLeft
        //self.view.addSubview(handView)
    }
    
    override public func viewDidLoad() {
        print("view did load")
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.session.delegate = self
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
                self.handView.image = UIImage(pixelBuffer: handBuffer)?.resized(to: CGSize(width: 828/2, height: 1792/2))
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



