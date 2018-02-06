//
//  DogClassifier.swift
//  WhatDog
//
//  Created by Ryan Yan on 12/21/17.
//

import CoreML
import Vision
import UIKit

protocol DogClassifierDelegate:class {
    func didFinishClassificationWith(dogType: String?)
}

class DogClassifier:NSObject{
    
    weak var delegate: DogClassifierDelegate?
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            /*
             Use the Swift class `MobileNet` Core ML generates from the model.
             To use a different Core ML classifier model, add it to the project
             and replace `MobileNet` with that model's generated Swift class.
             */
            let model = try VNCoreMLModel(for: MobileNet().fritz().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    func updateClassifications(for image: UIImage) {
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) else { fatalError("Unable to get image orientation.") }
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    private func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            
            if !classifications.isEmpty {
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(2)
                for classification in topClassifications{
                    for dogType in DogTypes.supportTypes{
                        if classification.identifier.lowercased().range(of:dogType.lowercased()) != nil{
                            self.delegate?.didFinishClassificationWith(dogType: dogType)
                            return
                        }
                    }
                }
                self.delegate?.didFinishClassificationWith(dogType: nil)
            }
        }
    }
}
