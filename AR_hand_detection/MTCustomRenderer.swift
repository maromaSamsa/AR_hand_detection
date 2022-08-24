//
//  MTCustomRenderer.swift
//  AR_hand_detection
//
//  Created by WTMH on 2022/7/25.
//

import ARHeadsetKit
import Metal

class MTCustomRenderer {
    unowned let renderer: MainRenderer
    
    var interface: ARInterface!
    
    required init(renderer: MainRenderer, library: MTLLibrary!) {
        self.renderer = renderer
        self.interface = ARInterface(renderer: self)
    }
}

extension MTCustomRenderer: CustomRenderer {
    func updateResources() {
        interface.updateResources()
    }
    
    func drawGeometry(renderEncoder: ARMetalRenderCommandEncoder) {
    }
}

protocol DelegateMTCustomRenderer {
    var customRenderer: MTCustomRenderer { get }
    init(renderer: MTCustomRenderer)
}

extension DelegateMTCustomRenderer{
    var mainRenderer: MainRenderer { customRenderer.renderer }
    var centralRenderer: CentralRenderer { mainRenderer.centralRenderer }
    var interfaceRenderer: InterfaceRenderer { mainRenderer.interfaceRenderer }
}
