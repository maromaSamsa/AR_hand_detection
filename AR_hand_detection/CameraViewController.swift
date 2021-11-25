//
//  CameraViewController.swift
//  AR_hand_detection
//
//  Created by WTMH on 2021/10/7.
//

import UIKit
import AVFoundation
import Vision
import ARKit
import RealityKit

// handling exception, use "throw" to call this Error protocol
enum AppError: Error {
    case captureSessionSetup(reason: String)
    case processPoints(reason: String)
}

// MARK: Main
final class CameraViewController: UIViewController{
    
    /// Use this property as view reference to access the view
    ///  - view: The view that the controller manages
    ///  - Computed property: loadView() will execute first and insure view has cast into reference of CameraPreview
    ///
    private var cameraView: CameraPreview {
        return view as! CameraPreview
    }
    
    /// Capture camera flow of data
    private var cameraFeedSession: AVCaptureSession?
    
    
    /// Controller to pick exacute thread
    private let videoDataOutputQueue = DispatchQueue(
      label: "CameraFeedOutput",
      qos: .userInteractive
    )
    
    // Hand detection request
    private let handPoseRequest: VNDetectHumanHandPoseRequest = {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 1
        return request
    }()
    
    // 1
    public var depthPixelBuffer: CVPixelBuffer?
    public var pointsProcessorHandler: (([CGPoint_3D]) -> Void)?
    func processPoints(_ fingerJoints: [CGPoint], _ jointsName: [VNHumanHandPoseObservation.JointName]) {
        
        var finalpoints: [CGPoint_3D] = []
        
        if !fingerJoints.isEmpty, depthPixelBuffer != nil{
            
            let width = CVPixelBufferGetWidth(depthPixelBuffer!)
            CVPixelBufferLockBaseAddress(depthPixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(depthPixelBuffer!), to: UnsafeMutablePointer<Float>.self)
        
            for (point, name) in zip(fingerJoints, jointsName){
                let convertedPoint = cameraView.previewLayer.layerPointConverted(fromCaptureDevicePoint: point)
                let pixelDepth = CGFloat(floatBuffer[Int(point.y * CGFloat(width) + point.x)])
                finalpoints.append(CGPoint_3D(jointName: name, jointPos: convertedPoint, depth: pixelDepth))
            }
        }
        // 3
        pointsProcessorHandler?(finalpoints)
    }
    
    
    
    

    /// Creates the view that the controller manages
    override func loadView() {
        view = CameraPreview()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do{
            if cameraFeedSession == nil {
                try setupAVSession() // set cameraFeedSession
                cameraView.previewLayer.session = cameraFeedSession
                cameraView.previewLayer.videoGravity = .resizeAspectFill
            }
            cameraFeedSession?.startRunning() // makes camera feed visible
        } catch {
            print(error.localizedDescription)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewWillDisappear(animated)
    }

}


// MARK: Setup AVCapture Session
extension CameraViewController{
    func setupAVSession() throws {
        // Check if the device has realword camera
        guard let videoDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back)
        else {
            throw AppError.captureSessionSetup(
                reason: "Could not find a back facing camera."
            )
        }

        // Check if you can use the camera to create a capture device input
        guard
        let deviceInput = try? AVCaptureDeviceInput(device: videoDevice)
        else {
            throw AppError.captureSessionSetup(
                reason: "Could not create video device input."
            )
        }

        // create a capture session and start configuring
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high

        // Check and add input data strem to session
        if session.canAddInput(deviceInput){
            session.addInput(deviceInput)
        } else {
            throw AppError.captureSessionSetup(
                reason: "Could not add video device input to the session"
            )
        }


        // set data output and add to session
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            session.addOutput(dataOutput)
        } else {
            throw AppError.captureSessionSetup(
                 reason: "Could not add video data output to the session"
            )
        }
        
        let depthOutput = AVCaptureDepthDataOutput()
        if session.canAddOutput(depthOutput){
            depthOutput.isFilteringEnabled = true
            depthOutput.alwaysDiscardsLateDepthData = true
            depthOutput.setDelegate(self, callbackQueue: videoDataOutputQueue)
            session.addOutput(depthOutput)
        } else {
            throw AppError.captureSessionSetup(
                reason: "Could not add depth data output to the session"
            )
        }

        // assign session back
        session.commitConfiguration()
        cameraFeedSession = session
    }
}


// MARK: Video output delegate
extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        var fingerJoints: [CGPoint] = []
        var fingerNames: [VNHumanHandPoseObservation.JointName] = []
        
        // call before exit function
        defer {
          DispatchQueue.main.sync {
            self.processPoints(fingerJoints, fingerNames)
          }
        }

        
        let handler = VNImageRequestHandler(
            cmSampleBuffer: sampleBuffer,
            orientation: .up,
            options: [:]
        )
        
        do{
            try handler.perform([handPoseRequest])
            
            guard let result = handPoseRequest.results?.prefix(1),
                  !result.isEmpty
            else{
                return
            }
            
            try result.forEach{ observation in
                let joints = try observation.recognizedPoints(.all)
                joints.forEach{ joint in
                    if joint.value.confidence > 0.9{
                        fingerNames.append(joint.key)
                        fingerJoints.append(CGPoint(x: joint.value.location.x, y: 1 - joint.value.location.y))
                    }
                }
            }
        }catch{
            cameraFeedSession?.stopRunning()
        }
    }
}

// MARK: Depth output delegate
extension CameraViewController: AVCaptureDepthDataOutputDelegate{
    public func depthDataOutput(_ output: AVCaptureDepthDataOutput, didOutput depthData: AVDepthData, timestamp: CMTime, connection: AVCaptureConnection) {
        
        let depthDataType = kCVPixelFormatType_DepthFloat32
        let convertedDepth: AVDepthData =
        {
            if depthData.depthDataType != depthDataType {
                return depthData.converting(toDepthDataType: depthDataType)
            }else{
                return depthData
            }
        }()
        let pixelBuffer = convertedDepth.depthDataMap
        
        DispatchQueue.main.async {
            self.depthPixelBuffer = pixelBuffer
        }
        
    }
}
