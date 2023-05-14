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
        ARContentView<SettingView>().environmentObject(Coordinator(appDescription: description))
    }
}

class MTMainRenderer: MainRenderer{
    override class var interfaceDepth: Float{ 0.7 }
    override var makeCustomRenderer: CustomRendererInitializer{
        MTCustomRenderer.init
    }
}


class Coordinator: AppCoordinator{
    var isRecording = false
    let semaphore = DispatchSemaphore(value: 10)
    let queue = DispatchQueue.init(label: "Recording hand using time", qos: .background )
    override var makeMainRenderer: AppCoordinator.MainRendererInitializer{
        MTMainRenderer.init
    }
    override func modifyCustomSettings(customSettings: inout [String : String]) {
        queue.async {
            if self.semaphore.wait(timeout: .distantFuture) == .success {
                if self.isRecording && !self.settingsAreShown{
                    print(NSDate(), self.handIsDetected)
                    self.showMirroredHand = !self.showMirroredHand
                }
                sleep(1)
                self.semaphore.signal()
            }
        }
    }
}

struct SettingView:CustomRenderingSettingsView{
    @ObservedObject var coordinator: Coordinator
    init(c: Coordinator) {
        self.coordinator = c
    }
    
    var body: some View{
        Toggle("Start Recording", isOn: $coordinator.isRecording)
    }
}



