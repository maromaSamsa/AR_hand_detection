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
            fatalError("can't load Vision ML model: \(error)")
        }
    }()
    
    public func performDetection(inputBuffer: CVPixelBuffer, output: @escaping (CVPixelBuffer?) -> Void ) -> Void {
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: inputBuffer, orientation: .right)
        
        visionQueue.async {
            do{
                try requestHandler.perform([self.predictionRequest])
                guard let observation = self.predictionRequest.results?.first as? VNPixelBufferObservation else {
                    fatalError("Unexpected result type from VNCoreMLRequest")
                }
                output(observation.pixelBuffer)
            } catch {
                output(nil)
            }
        }
    }
}
