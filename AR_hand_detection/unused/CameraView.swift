//
//  CameraView.swift
//  AR_hand_detection
//
//  Created by WTMH on 2021/10/7.
//


import SwiftUI

/// To add view controller into SwiftUI interface, create your UIViewControllerRepresentable instance and add it to your SwiftUI interface. The system calls the methods of your custom instance at appropriate times.
struct CameraView: UIViewControllerRepresentable {
    // ?
    var pointsProcessorHandler: (([CGPoint]) -> Void)?
    
    /// The system calls this method only once, when it creates your view controller for the first time
    func makeUIViewController(context: Context) -> CameraViewController {
        let cvc = CameraViewController()
        // ?
        cvc.pointsProcessorHandler = pointsProcessorHandler
        return cvc
    }
    
    /// SwiftUI calls this method for any changes affecting the corresponding AppKit view controller
    func updateUIViewController(
        _ uiViewController: CameraViewController,
        context: Context
    ){}
}
