//
//  ProcessingViewModel.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 12/17/21.
//

import Foundation
import CoreML
import SwiftUI

final class ProcessingViewModel: ObservableObject {
    @Published var imageInProcessing = false
    @Published var currentModel: MLModels = MLModels.gaussianMask
    @Published var workingImage : GalleryImage = GalleryImage(name: "12219")
    @Published var loadingActivations: Bool = false
    @Published var imageDidProcess: Bool = false
    @Published var mlArrayOutput : MLMultiArray? = nil
    @Published var cgImageOutput : CGImage? = nil
    
    func processImage( ) {
        loadingActivations = true
        if let uiImage = UIImage(named: workingImage.name ) {
            // Model output call
            do {
                (mlArrayOutput, cgImageOutput) = try getCGActivations(image: uiImage, modelType: currentModel)!
                loadingActivations = false
                imageDidProcess = true
            } catch { }
        } else { imageDidProcess = false}
    }
}
