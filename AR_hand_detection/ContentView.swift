//
//  ContentView.swift
//  AR_hand_detection
//
//  Created by WTMH on 2021/10/5.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack{
            CameraView().edgesIgnoringSafeArea(.all)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
