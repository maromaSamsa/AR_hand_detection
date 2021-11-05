//
//  ContentView.swift
//  AR_hand_detection
//
//  Created by WTMH on 2021/10/5.
//

import SwiftUI

struct ContentView: View {
    // ?
    @State private var overlayPoints: [CGPoint] = []
    var body: some View {
        ZStack{
            CameraView {
              overlayPoints = $0
            }
            .overlay(
              FingersOverlay(with: overlayPoints)
                .foregroundColor(.orange)
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
