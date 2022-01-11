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
import LASwift


final class SegNetIOManager {
    
    static let shared = SegNetIOManager()
    
    private var _workingImageName : String?
    private var _workingImage     : CGImage?
    private var _currentModel     : MLModels = MLModels.gaussianMask
    private var _mlMatrixOutput   : Matrix?
    private var _cgModelOutput    : CGImage?
    private var _cgSegments       : CGImage?
    private var _SegmentsBinary   : Matrix?
    private var _threshold        : Float64 = 0.0
    private var _serReader        : FileSer?
    private var _serHeader        : SerHeader?

    func initializeSerImage(completed: @escaping ( Result<CGImage, Error> ) -> Void ) {
        do {
            
            _serReader = try FileSer.init(filename: _workingImageName, mobileBundle: false)
            try _serReader?.readHeader()
            _serHeader = _serReader?.Head
            _workingImage = try _serReader?.GetCGImageFromSer()
            completed(.success( _workingImage! ))
        }
        catch { completed(.failure(error))}
        
    }
    
    func processImage(completed: @escaping (Result< CGImage, Error> ) -> Void) {
        guard let inputImage = _workingImage else {
            completed(.failure( "working image was nil" ))
            return
        }
//        guard let uiImage = UIImage(named: inputImage.name ) else {
//            completed(.failure( "Could not get UIImage from image named \(inputImage.name)" ))
//            return
//        }
        
        // Model output call
        do {
            (_mlMatrixOutput, _cgModelOutput) = try getCGActivations(image: inputImage, modelType: _currentModel)
            completed(.success( _cgModelOutput! )) //MARK: unsafe
            return
        } catch let error { completed(.failure( error )) }
        
//        //Segmentation
//        //Otsu thresholding
//        var histogramCounts =
//        _mlArrayOutput!.flat
//        let total = sum( _mlArrayOutput! )
//        var top = 256
//        var sumB = 0
//        var wB = 0
//        var maximum = 0.0
//        var sum1 = dot( (0...top-1).map { Double($0)},  )
//        for i in 0..<top {
//            wF = total - wB;
//            if wB > 0 && wF > 0
//                mF = (sum1 - sumB) / wF;
//                val = wB * wF * ((sumB / wB) - mF) * ((sumB / wB) - mF);
//                if ( val >= maximum )
//                    level = ii;
//                    maximum = val;
//                end
//            end
//            wB = wB + histogramCounts(i );
//            sumB = sumB + ( i-1) * histogramCounts( i );
//        }
    }
        
    func setCurrentModel( _ to: MLModels ) {
        _currentModel = to
    }
    
    func setHResCurrentModel( _ to: MLModels ) {
        _currentModel = to
    }
    
    func setWorkingImage( _ to: CGImage) {
        _workingImage = to
    }
    
    func setWorkingImageName( _ to: String) {
        _workingImageName = to
    }
    
    func getCurrentModel() -> MLModels {
        return _currentModel
    }
    func getWorkingImage() -> CGImage? {
        return _workingImage
    }
    func getWorkingImageName() -> String? {
        return _workingImageName
    }
        
}

