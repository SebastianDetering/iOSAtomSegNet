//
//  ModelProcessManager.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 12/18/21.
//

import Foundation
import CoreGraphics
import CoreML
import SwiftUI

final class SegNetIOManager {
    
    static let shared = SegNetIOManager()
    
    private var _workingImage : GalleryImage = GalleryImage(name: "12219")
    private var _currentModel: MLModels = MLModels.gaussianMask
    private var _mlArrayOutput : MLMultiArray? = nil
    private var _cgImageOutput : CGImage? = nil

    func processImage(completed: @escaping (Result< CGImage, Error> ) -> Void) {
        guard let uiImage = UIImage(named: _workingImage.name ) else {
            completed(.failure( "Could not get UIImage from image named \(_workingImage.name)" ))
            return
        }
        
            // Model output call
            do {
                (_mlArrayOutput, _cgImageOutput) = try getCGActivations(image: uiImage, modelType: _currentModel)
                completed(.success( _cgImageOutput! )) //MARK: unsafe
                return
            } catch let error { completed(.failure( error )) }
         
    }
        
    func setCurrentModel( _ to: MLModels ) {
        _currentModel = to
    }
    
    func setHResCurrentModel( _ to: MLModels ) {
        _currentModel = to
    }
    
    func setWorkingImage( _ to: GalleryImage) {
        _workingImage = to
    }
    
    func getCurrentModel() -> MLModels {
        return _currentModel
    }
    
    func getWorkingImage() -> GalleryImage {
        return _workingImage
    }
        
}

