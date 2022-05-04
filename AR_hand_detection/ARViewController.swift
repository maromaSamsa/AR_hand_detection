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
        self.view = self.testCameraView_base
        self.view.addSubview(self.testCameraView)
    }
    
    override public func viewDidLayoutSubviews() {
        print("view did layout subviews")
        self.testCameraView.frame = self.view.bounds
        self.handView.frame = self.testCameraView.bounds
    }
    
    override public func viewDidLoad() {
        print("view did load")
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.preferredFramesPerSecond = 60
        
        self.testCameraView_base.transform = CGAffineTransform.identity.rotated(by: .pi/2)
        self.testCameraView.transform = CGAffineTransform.identity.scaledBy(x: -1, y: 1)
        self.handView.transform = CGAffineTransform.identity.rotated(by: -.pi/2)
        self.testCameraView.mask = self.handView
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
        defer {
            //print(frame.timestamp) // testing fps
            DispatchQueue.main.async {
                self.handMaskBuffer = nil
                self.currentBuffer = nil
            }
        }
        self.currentBuffer = frame.capturedImage
        handDetector.performDetection(inputBuffer: self.currentBuffer!){
            outputBuffer in
            self.handMaskBuffer = outputBuffer
        }
        startRendering()
    }
    
    private func startRendering() -> Void {
        guard let handBuffer = self.handMaskBuffer else{
            return
        }
        guard let cameraBuffer = self.currentBuffer else{
            return
        }
        DispatchQueue.main.async {
            let ci = CIImage(cvPixelBuffer: cameraBuffer)
            let ui = UIImage(ciImage: ci)
            self.testCameraView.image = ui
            self.handView.image = UIImage(pixelBuffer: handBuffer)
            self.testCameraView_base.image = ui
            //print("subview f&b", self.testCameraView.frame.size, self.testCameraView.bounds.size)
            //print("view f&b", self.testCameraView_base.frame, self.testCameraView_base.bounds)
        }
    }
    
}

extension ARViewController: ARSCNViewDelegate{

}



