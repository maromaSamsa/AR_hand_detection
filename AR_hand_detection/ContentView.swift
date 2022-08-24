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
        let description = AppCoordinator.AppDescription(name: "ARMT APP")
        ARContentView<EmptySettingsView>().environmentObject(Coordinator(appDescription: description))
    }
}

class MTMainRenderer: MainRenderer{
    override class var interfaceDepth: Float{ 0.7 }
    override var makeCustomRenderer: CustomRendererInitializer{
        MTCustomRenderer.init
    }
}


class Coordinator: AppCoordinator{
    override var makeMainRenderer: AppCoordinator.MainRendererInitializer{
        MTMainRenderer.init
    }
}



