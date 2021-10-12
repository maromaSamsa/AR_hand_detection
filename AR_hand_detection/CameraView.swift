//
//  CameraView.swift
//  AR_hand_detection
//
//  Created by WTMH on 2021/10/7.
//

import SwiftUI


struct CameraView: UIViewControllerRepresentable {
  
  func makeUIViewController(context: Context) -> CameraViewController {
    let cvc = CameraViewController()
    return cvc
  }

  func updateUIViewController(
    _ uiViewController: CameraViewController,
    context: Context
  ) {
  }
}
