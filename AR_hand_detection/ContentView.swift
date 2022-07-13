//
//  ContentView.swift
//  AR_hand_detection
//
//  Created by maromasamsa on 2022/7/14.

import SwiftUI
import ARHeadsetKit
import Metal

struct ContentView: View {
    var body: some View {
        let description = AppCoordinator.AppDescription(name: "Demo App")
        ARContentView<EmptySettingsView>().environmentObject(Coordinator(appDescription: description))
    }
}

class My_MainRenderer: MainRenderer{
    override class var interfaceDepth: Float{ 0.9 }
    
}

class Coordinator: AppCoordinator{
    override var makeMainRenderer: AppCoordinator.MainRendererInitializer{
        My_MainRenderer.init
    }
}



