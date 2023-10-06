//
//  TextRecogniser.swift
//  alle_assignment
//
//  Created by Piyush Sharma on 04/10/23.
//

import Foundation
import UIKit
import Vision
import CoreData

class ImageProcessor {
    
    static let shared = ImageProcessor()
    
    private init(){
        loadMachineLearningModel()
    }
    
    private var coreMLModel: VNCoreMLModel?
    
    private func loadMachineLearningModel() {
        do {
            let configuration = MLModelConfiguration()
            let model = try VNCoreMLModel(for: Resnet50(configuration: configuration).model)
            coreMLModel = model
        } catch {
            print("Error initializing the model: \(error.localizedDescription)")
        }
    }
    
    func checkOrCreateEntry(for id: String, _ image: UIImage) {
        DispatchQueue.main.async {
            let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest = Screenshot.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            let result = try! moc.fetch(fetchRequest)
            
            if result.isEmpty {
                self.processImage(id, image)
            }
        }
    }
    
    func processImage(_ id: String,_ image: UIImage){
        self.processImageWithVision(for: image) { descriptionResult in
            self.processImageWithVisionForLabeling(image) { labelResult in
                DispatchQueue.main.async {
                    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    let fetchRequest = Screenshot.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                    let result = try! moc.fetch(fetchRequest)
                    var ss = Screenshot(context: moc)
                    ss.id = id
                    ss.imageDescription = descriptionResult
                    ss.isProcessed = true
                    let labelResultData = try! JSONEncoder().encode(labelResult)
                    ss.labels = labelResultData
                    
                    
                    try! moc.save()
                }
            }
        }
        
    }
    
    func processImageWithVision(for image: UIImage, completion: @escaping ((String) -> ())){
        var resultString: String = ""
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("Error processing the image: \(error.localizedDescription)")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            for observation in observations {
                if let topCandidate = observation.topCandidates(1).first {
                    
                    resultString = resultString + " " + topCandidate.string
                }
            }
            print(resultString)
            completion(resultString)
        }
        
        request.recognitionLevel = .fast
        
        let requests = [request]
        guard let cgImage = image.cgImage else {
            print("Failed to get CGImage from UIImage.")
            return
        }
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try imageRequestHandler.perform(requests)
        } catch {
            print("Failed to perform image request: \(error.localizedDescription)")
        }
        
        
    }
    
    func processImageWithVisionForLabeling(_ image: UIImage, completion: @escaping (([String]) -> ())) {
        guard let cgImage = image.cgImage, let model = coreMLModel else {
            print("Failed to get CGImage from UIImage.")
            return
        }
        
        
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation], let topResult = results.first else {
                print("Unexpected result type from VNCoreMLRequest.")
                return
            }
            
            let identifier = topResult.identifier  // The label of the recognized object.
            let confidence = topResult.confidence  // The confidence of the recognition, ranging from 0 to 1.
            completion(identifier.split(separator: ",").map{String($0)})
            print("Label: \(identifier), Confidence: \(confidence)")
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform classification: \(error.localizedDescription)")
        }
        
    }
}
