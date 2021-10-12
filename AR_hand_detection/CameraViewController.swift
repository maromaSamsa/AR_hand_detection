//
//  CameraViewController.swift
//  AR_hand_detection
//
//  Created by WTMH on 2021/10/7.
//

import UIKit
import AVFoundation

enum AppError: Error {
  case captureSessionSetup(reason: String)
}

final class CameraViewController: UIViewController{
    
    private var cameraView: CameraPreview { view as! CameraPreview }
    private var cameraFeedSession: AVCaptureSession?
    private let videoDataOutputQueue = DispatchQueue(
      label: "CameraFeedOutput",
      qos: .userInteractive
    )

    
    override func loadView() {
        view = CameraPreview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      
      do {
        if cameraFeedSession == nil {
          try setupAVSession()
          cameraView.previewLayer.session = cameraFeedSession
          cameraView.previewLayer.videoGravity = .resizeAspectFill
        }
        cameraFeedSession?.startRunning()
      } catch {
        print(error.localizedDescription)
      }
    }

    override func viewWillDisappear(_ animated: Bool) {
      cameraFeedSession?.stopRunning()
      super.viewWillDisappear(animated)
    }

    func setupAVSession() throws {
      // 1
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
      else {
        throw AppError.captureSessionSetup(
          reason: "Could not find a front facing camera."
        )
      }

      // 2
      guard
        let deviceInput = try? AVCaptureDeviceInput(device: videoDevice)
      else {
        throw AppError.captureSessionSetup(
          reason: "Could not create video device input."
        )
      }

      // 3
      let session = AVCaptureSession()
      session.beginConfiguration()
      session.sessionPreset = AVCaptureSession.Preset.high

      // 4
      guard session.canAddInput(deviceInput) else {
        throw AppError.captureSessionSetup(
          reason: "Could not add video device input to the session"
        )
      }
      session.addInput(deviceInput)

      // 5
      let dataOutput = AVCaptureVideoDataOutput()
      if session.canAddOutput(dataOutput) {
        session.addOutput(dataOutput)
        dataOutput.alwaysDiscardsLateVideoFrames = true
        dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
      } else {
        throw AppError.captureSessionSetup(
          reason: "Could not add video data output to the session"
        )
      }
      
      // 6
      session.commitConfiguration()
      cameraFeedSession = session
    }


}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
}
