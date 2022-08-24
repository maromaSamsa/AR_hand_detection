//
//  ARInterface.swift
//  AR_hand_detection
//
//  Created by WTMH on 2022/7/25.
//

import ARHeadsetKit
import Metal

class ARInterface: DelegateMTCustomRenderer {
    unowned let customRenderer: MTCustomRenderer
    
    static var interfaceScale: Float = .nan
    
    var reactionParams: (text: String, location: simd_float3)?
    
    required init(renderer: MTCustomRenderer){
        self.customRenderer = renderer
    }
}



extension ARInterface {
    func updateResources() {
        //Self.interfaceScale = customRenderer.interfaceScale
        let segments: [ARParagraph.StringSegment] = [
            (string: "ARMT", fontID: 0)
            //, (string: "str_1,", fontID: 1),
            //(string: "str_2", fontID: 2)
        ]
        
        let elementWidth: Float = 0.15
               
        let paragraph = InterfaceRenderer.createParagraph(
           stringSegments: segments,
           width: elementWidth,
           pixelSize: 0.25e-3
        )
       
       let characterGroups = paragraph.characterGroups
       let suggestedHeight = paragraph.suggestedHeight
       
       let element = ARInterfaceElement(
           position: [0, 0, -0.3],
           forwardDirection: [0, 0, 1],
           orthogonalUpDirection: [0, 1, 0],
           
           width: elementWidth,
           height: suggestedHeight,
           depth: 0.05, radius: 0.02,
           
           characterGroups: characterGroups
       )
       
       interfaceRenderer.render(element: element)
    }
}
