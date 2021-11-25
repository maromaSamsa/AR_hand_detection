//
//  CGPoint_3D.swift
//  AR_hand_detection
//
//  Created by cloudhuang on 2021/11/25.
//

import CoreGraphics
import Vision


final class CGPoint_3D{
    
    var name: VNHumanHandPoseObservation.JointName
    var point: CGPoint
    var depth: CGFloat
    
    init(jointName: VNHumanHandPoseObservation.JointName, jointPos: CGPoint, depth: CGFloat
)
    {
        self.name = jointName
        self.point = jointPos
        self.depth = depth
    }
    
    static func distance(p1: CGPoint_3D, p2: CGPoint_3D) -> Float{
        // unit is an unsolved problem for now
        // https://stackoverflow.com/questions/1965804/how-to-get-meters-in-pixel-in-mapkit
        let d_x = pow(p1.point.x - p2.point.x, 2.0) // unit: pixel
        let d_y = pow(p1.point.y - p2.point.y, 2.0) // unit: pixel
        let d_z = pow(p1.depth - p2.depth, 2.0) // unit: meter
        return sqrtf(Float(d_x + d_y + d_z));
    }
    
    public func getCGPoint() -> CGPoint{
        return self.point
    }
    
}
