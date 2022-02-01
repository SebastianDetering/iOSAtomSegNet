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

enum SegNetDataTypes {
    case Images
    case SerFile
    case DM3File
}

final class SegNetIOManager {
    
    static private var _workingBinaryData: Data!
    @Published var sourceImage      : CGImage!
    @Published var sourceImageName  : String!   // for viewing in the gallery
    
    static private var _workingImageName : String!   // for seeing as the inputs to model
    static private var _workingImage     : CGImage!
    static private var _workingSerData   : CGImage! // 32 bit depth max supported
    static private var _currentModel     : MLModels = MLModels.gaussianMask
    static private var _mlMatrixOutput   : Matrix!
    static private var _cgModelOutput    : CGImage!     // outputs of model.
    static private var _cgSegments       : CGImage!
    static private var _SegmentsBinary   : Matrix!
    static private var _threshold        : Float64 = 0.0
    static private var _serReader        : FileSer!
    static private var _serHeader        : SerHeader!
    static private var _headerDescription: SerHeaderDescription!
    
    static private var _sourceDType: SegNetDataTypes = .Images
    static private var _workingDType: SegNetDataTypes = .SerFile

    static func InitializeSerInfo(completed: @escaping ( Result<SerHeaderDescription, Error> ) -> Void ) {
        do {
            _serReader = try FileSer.init(filename: _workingImageName, mobileBundle: false)
            try _serReader?.readHeader()
            _serHeader = _serReader?.Head
            _headerDescription = _serReader?.getHeaderDescription()
            _sourceDType = .SerFile
            completed(.success( _headerDescription! ))
        }
        catch { completed(.failure(error)) }
        
    }
    
    static func LoadSerImage(completed: @escaping ( Result<CGImage, Error> ) -> Void ) {
        do {
            _workingSerData = try _serReader?.GetHighDefCGImageFromSer()
            completed(.success( _workingSerData! ))
        }
        catch { completed(.failure(error)) }
        
    }
    static func getSourceType() -> SegNetDataTypes {
        return _sourceDType
    }
    static func getWorkingType() -> SegNetDataTypes {
        return _workingDType
    }
    
    static func getBinary() -> Data {
        _workingBinaryData = _serReader.getData()
        return _workingBinaryData
    }
    static func getHeader() -> SerHeader {
        return _serHeader!
    }
    static func getHeaderDescription() -> SerHeaderDescription {
        return _headerDescription
    }
    
    static func processImage(completed: @escaping (Result< CGImage, Error> ) -> Void) {
        guard let inputImage = _workingImage else {
            completed(.failure( ModelIOErrors.MissingSourceImage ))
            return
        }
        // Model output call
        do {
            switch _sourceDType {
            case .Images:
                (_mlMatrixOutput, _cgModelOutput) = try getCGActivations(image: inputImage, modelType: _currentModel)
                completed(.success( _cgModelOutput! )) //MARK: unsafe
                return
            case .SerFile:
                (_mlMatrixOutput, _cgModelOutput) = try getCGActivations(image: inputImage, modelType: _currentModel)
                completed(.success( _cgModelOutput! )) //MARK: unsafe
                return
            case .DM3File:
                completed(.failure(ModelIOErrors.MissingSourceImage   ))
            }
            
        } catch let error { completed(.failure( error )) }
    }
        
    static func setCurrentModel( _ to: MLModels ) {
        _currentModel = to
    }
    
    static func setHResCurrentModel( _ to: MLModels ) {
        _currentModel = to
    }
    
    static func setWorkingImage( _ to: CGImage) {
        _workingImage = to
    }
    
    static func setWorkingImageName( _ to: String) {
        _workingImageName = to
    }
    
    static func getCurrentModel() -> MLModels {
        return _currentModel
    }
    static func getWorkingImage() -> CGImage? {
        return _workingImage
    }
    static func getWorkingImageName() -> String? {
        return _workingImageName
    }
        
}

