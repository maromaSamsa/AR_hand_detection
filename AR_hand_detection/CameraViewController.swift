//
//  CameraViewController.swift
//  AR_hand_detection
//
//  Created by WTMH on 2021/10/7.
//

import UIKit
import AVFoundation
import Vision

// handling exception, use "throw" to call this Error protocol
enum AppError: Error {
  case captureSessionSetup(reason: String)
}


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

    /// Creates the view that the controller manages
    override func loadView() {
        view = CameraPreview()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
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

    func setupAVSession() throws {
        // Check if the device has realword camera
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
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

        // assign session back
        session.commitConfiguration()
        cameraFeedSession = session
    }


}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        var thumbTip: CGPoint?
    }
}
