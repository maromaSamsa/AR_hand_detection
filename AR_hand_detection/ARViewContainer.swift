//
//  ARViewContainer.swift
//  AR_hand_detection
//
//  Created by maromasamsa on 2022/3/8.
//

import SwiftUI

/// A container for UIViewController in SwiftUI framework
struct ARViewContainer: UIViewControllerRepresentable{
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return ARViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // maybe write a timer to measure fps?
    }
}
