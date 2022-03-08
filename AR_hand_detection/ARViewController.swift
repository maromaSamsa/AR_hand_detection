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
    private var mask = UIImageView()
    private let handDetector = HandDetector()
    private var currentBuffer: CVPixelBuffer?
    
    override public func loadView() {
        print("load view")
        super.loadView()
        self.view = mask
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
    }
    private func startDetection() -> Void{
        guard let buffer = self.currentBuffer else{
            return
        }
        handDetector.performDetection(inputBuffer: buffer){
            outputPixelBuffer in
            
            var previewImage: UIImage?
            
            guard let outputBuffer = outputPixelBuffer else{
                return
            }
            defer{
                DispatchQueue.main.async {
                    self.mask.image = previewImage
                    self.currentBuffer = nil
                }
            }
            
            previewImage = UIImage(ciImage: CIImage(cvPixelBuffer: outputBuffer))
            
        }
    }
    
}

extension ARViewController: ARSCNViewDelegate{

}



