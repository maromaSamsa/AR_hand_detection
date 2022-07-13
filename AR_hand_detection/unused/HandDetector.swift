//
//  HandDetector.swift
//  AR_hand_detection
//
//  Created by maromasamsa on 2022/3/8.
//

import CoreML
import Vision

final class HandDetector{
    private let visionQueue = DispatchQueue(label: "HandContour")
    
    private lazy var predictionRequest: VNCoreMLRequest = {
        do{
            let config = MLModelConfiguration()
            config.allowLowPrecisionAccumulationOnGPU = true
            let model = try VNCoreMLModel(for: HandModel(configuration: config).model)
            let request = VNCoreMLRequest(model: model)
            request.imageCropAndScaleOption = .scaleFill
            return request
        }catch{
            fatalError("Can't load Vision ML model: \(error)")
        }
    }()
    
    public func performDetection(inputBuffer: CVPixelBuffer, output: @escaping (CVPixelBuffer?) -> Void ) -> Void {
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: inputBuffer, orientation: .up)
        
        // Set to background thread
        visionQueue.sync {
            do{
                try requestHandler.perform([self.predictionRequest])
                guard let observation = self.predictionRequest.results?.first as? VNPixelBufferObservation else {
                    fatalError("Unexpected result type from VNCoreMLRequest")
                }
                // You must call the CVPixelBufferLockBaseAddress(_:_:) function before accessing pixel data
                CVPixelBufferLockBaseAddress(
                    observation.pixelBuffer, CVPixelBufferLockFlags(rawValue: 0)
                )

                if CVPixelBufferGetBaseAddress(observation.pixelBuffer) != nil {
                    // this pointer offset is count as size of byte
                    let ptr = unsafeBitCast(CVPixelBufferGetBaseAddress(observation.pixelBuffer), to: UnsafeMutablePointer<UInt8>.self)
                    let bytesPerRow = CVPixelBufferGetBytesPerRow(observation.pixelBuffer)
                    let size = (
                        height: CVPixelBufferGetHeight(observation.pixelBuffer),
                        width: CVPixelBufferGetWidth(observation.pixelBuffer)
                    )
                    
                    // in debug mode, use "stride" is more effient than using "for" loop
                    for y in stride(from: 0, to: size.height, by: 1){
                        for x in stride(from: 0, to: size.width, by: 1){
                            let offset = bytesPerRow * y + (bytesPerRow/size.width) * x
                            if ptr[offset] == 0{
                                ptr[offset + 3] = 0 // alpha
                            }
        //                    ptr[offset + 0] // blue
        //                    ptr[offset + 1] // green
        //                    ptr[offset + 2] // red
        //                    ptr[offset + 3] // alpha
                        }
                    }

                }
                CVPixelBufferUnlockBaseAddress(
                    observation.pixelBuffer, CVPixelBufferLockFlags(rawValue: 0)
                )

                output(observation.pixelBuffer)
            } catch {
                output(nil)
            }
        }
    }
}
