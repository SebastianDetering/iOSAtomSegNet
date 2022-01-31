//
//  ProcessingViewModel.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 12/17/21.
//

import Foundation
import CoreML
import SwiftUI
import UIKit

enum SourceTypes {
    case Image
    case Ser
}

final class ProcessingViewModel: ObservableObject {
    
    @Published var currentModel: MLModels = SegNetIOManager.getCurrentModel()

    @Published var sourceImageLoaded = false
    @Published var imageInProcessing = false
    @Published var isLoadingActivations = false
    @Published var imageDidProcess = false
    
    @Published var sourceImage: CGImage?
    @Published var cgImageOutput : CGImage?

    @Published var workingImageName: String?
    @Published var newWorkingImageName: String?
    
    @Published var alertItem: AlertItem?
    
    func newSourceImage( sourceType: SourceTypes, imageName: String ) {
        switch sourceType {
        
        case .Image:
            sourceImageLoaded = false
            imageDidProcess = false
            sourceImage = UIImage( named: imageName )?.cgImage
            imageInProcessing = true
            sourceImageLoaded = true
        case .Ser:
            sourceImageLoaded = false
            imageDidProcess = false
            let serialQueue = DispatchQueue( label: "queue.Serial" )
            self.imageInProcessing = true
            self.workingImageName = imageName
            serialQueue.async {
            SegNetIOManager.setWorkingImageName(imageName)
            SegNetIOManager.InitializeSerImage() {
                result in
                DispatchQueue.main.async {
                switch result {
                case .success(let cgOut):
                    SegNetIOManager.setWorkingImage( cgOut )
                    self.sourceImage = cgOut
                    self.sourceImageLoaded = true
                case .failure(let error):
                    print(error.localizedDescription)
               }
                }
            }
            }
            print("ser source")
        }
    }
    
    func processImage() throws {
        guard let workingImage = sourceImage else { throw ModelIOErrors.MissingSourceImage }
        SegNetIOManager.setWorkingImage( workingImage )
        SegNetIOManager.setCurrentModel( currentModel )
        let serialQueue = DispatchQueue( label: "queue.Serial" )
        imageDidProcess = false
        isLoadingActivations = true
        // This queue setup is how to make the spinner view update the way you want to.
        // The idea is to do view updates on the main thread, and image processing/model call on the background thread.
        serialQueue.async {
            if Thread.isMainThread {
                print("main Thread task")
            }
            else { print("Background thread task")}
            
        SegNetIOManager.processImage() {
            result in
            DispatchQueue.main.async {
            self.isLoadingActivations = false
            switch result {
            case .success(let cgOut):
                self.imageDidProcess = true
                self.cgImageOutput = cgOut
            case .failure(let error):
                self.isLoadingActivations = false
                print(error.localizedDescription)
           }
            }
        
        }
        }
    }
}
