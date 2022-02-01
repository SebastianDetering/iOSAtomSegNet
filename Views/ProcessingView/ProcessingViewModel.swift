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

final class ProcessingViewModel: ObservableObject {
    
    @Published var currentModel: MLModels = SegNetIOManager.getCurrentModel()

    @Published var inspectingImage   = false
    @Published var sourceImageLoaded = false
    @Published var imageInProcessing = false
    @Published var isLoadingActivations = false
    @Published var imageDidProcess = false
    
    @Published var sourceImageDType: SegNetDataTypes?
    @Published var workingImageDType: SegNetDataTypes?
    @Published var sourceImage: CGImage? // inspecting
    @Published var workingImage: CGImage? // process source
    @Published var cgImageOutput : CGImage? // outputs

    @Published var workingImageName: String?
    @Published var newWorkingImageName: String?
    
    @Published var alertItem: AlertItem?
    
    func newSourceImage(imageType: SegNetDataTypes, image: CGImage? ) {
        sourceImageDType = imageType
        sourceImage = image
    }
    
    func setWorkingImage() {
        workingImageDType = sourceImageDType
        workingImage = sourceImage
    }
    
    func processImage() throws {
        if workingImage != nil {
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
}
