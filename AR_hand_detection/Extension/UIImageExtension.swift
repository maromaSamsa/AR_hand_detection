//
//  UIImageExtension.swift
//  AR_hand_detection
//
//  Created by maromasamsa on 2022/3/16.
//

import UIKit
import VideoToolbox

extension UIImage {
    public func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    /// This extension init method only works for RGB pixel buffer
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        guard let cgImage = cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}
