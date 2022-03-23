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

enum ProcessingStatus {
    case NoSource
    case ReadyToProcess
    case ProcessCompleted
    case Oversized
    case ProcessError
    case Saved
    case Processing
}

final class ProcessingViewModel: ObservableObject {
    
    @Published var currentModel: MLModels = SegNetIOManager.getCurrentModel()

    @Published var inspectingImage   = false
    @Published var loadingSourceImage = false
    @Published var sourceImageLoaded = false
    @Published var imageInProcessing = false
    @Published var isLoadingActivations = false
    @Published var imageDidProcess = false
    
    @Published var sourceImageDType: SegNetDataTypes?
    @Published var workingImageDType: SegNetDataTypes?
    
    @Published var tempSourceID: UUID?
    @Published var currSourceID: UUID?
    @Published var outputEntityID: UUID?
    @Published var sourceImage: CGImage? // inspecting
    @Published var workingImage: CGImage? // process source
    @Published var cgImageOutput : CGImage? // outputs
    
    @Published var workingImageName: String?
    @Published var sourceImageName: String?
    @Published var modelUsed: String?
    
    @Published var alertItem: AlertItem?
    @Published var processStatus: ProcessingStatus = .NoSource

    let topGradientColor = Color.brandBackground
    let bottomGradientColor = Color.brandBackground2
    
    func setWorkingImage() {
        workingImageName = sourceImageName
        workingImageDType = sourceImageDType
        workingImage = sourceImage
    }
    
    func clearOuputsImage() { // clear outputs if we move to the neural network with a new source image
        
        if tempSourceID != currSourceID { // different source image, clear outputs panel
            cgImageOutput = nil
        }
        currSourceID = tempSourceID
    }
    func newSourceImage( sourceType: SegNetDataTypes,
                         image: Data?, imageName: String,
                         id: UUID?, serEntity: Binding<SerEntity?> = .constant(nil)) {
        loadingSourceImage = true
            guard let imageID = id as? UUID else { // note im not allowing any images to show if they dont have UUID (helps for core data management of assets)
                return
            }
            tempSourceID = imageID
            sourceImageDType = sourceType
        switch sourceType {
        case .Images:
            if (image != nil){
            sourceImageName = imageName
            sourceImage = UIImage(data: image!)?.cgImage
            sourceImageLoaded = true
            } else {
                print("source Image data was nil")
                sourceImageLoaded = false
            }
        case .SerFile:
            sourceImageName = imageName
            sourceImageLoaded = false
            imageDidProcess = false
            let serialQueue = DispatchQueue( label: "queue.Serial" )
            self.workingImageName = imageName
            serialQueue.async {
                SegNetIOManager.LoadSerImage() {
                    result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let cgOut):
                            print("successfully read Ser image data")
                            serEntity.wrappedValue?.imageData = UIImage(cgImage: cgOut).pngData()
                            self.sourceImage = cgOut
                            self.sourceImageLoaded = true
                            self.loadingSourceImage = false
                        case .failure(let error):
                            print(error.localizedDescription)
                            self.loadingSourceImage = false
                        }
                    }
                }
            }
        case .DM3File:
            print("DM3 file not programmed yet.")
        }
        if (sourceImage?.width ?? 1000 <= 512) && (sourceImage?.height ?? 1000 <= 512) {
            processStatus = .ReadyToProcess
        } else {
            processStatus = .Oversized
        }
    }
    
    func processImage() throws {
        processStatus = .Processing
        if workingImage != nil {
            SegNetIOManager.setCurrentModel( currentModel )
            let serialQueue = DispatchQueue( label: "queue.Serial" )
            imageDidProcess = false
            isLoadingActivations = true
            // This queue setup is how to make the spinner view update the way you want to.
            // The idea is to do view updates on the main thread, and image processing/model call on the background thread.
            // used to crash rarely (related to background threading, but it doesn't as of Jan 2022
            serialQueue.async {
                SegNetIOManager.processImage(workingImage: self.workingImage) {
                    result in
                    DispatchQueue.main.async {
                        self.isLoadingActivations = false
                        switch result {
                        case .success(let cgOut):
                            self.imageDidProcess = true
                            self.cgImageOutput = cgOut
                            self.processStatus = .ProcessCompleted
                            self.outputEntityID = UUID()
                            self.modelUsed = self.currentModel.rawValue
                        case .failure(let error):
                            self.isLoadingActivations = false
                            self.processStatus = .ProcessError
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        } else { throw ModelIOErrors.MissingSourceImage}
    }
}
