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
    case EmiFile
}

final class SegNetIOManager {
    
    static private var _workingBinaryData: Data! // ser file binary
    
    static private var _currentModel     : MLModels = MLModels.gaussianMask
    
//    static private var _mlMatrixOutput   : Matrix!
//    static private var _cgModelOutput    : CGImage!     // outputs of model.
//    static private var _cgSegments       : CGImage!
//    static private var _SegmentsBinary   : Matrix!
    static private var _threshold        : Float64 = 0.0
    static private var _serReader        : FileSer!
    static private var _serHeader        : SerHeader!
    static private var _headerDescription: SerHeaderDescription!
    
    static private var _sourceDType: SegNetDataTypes = .Images
    static private var _workingDType: SegNetDataTypes = .SerFile

    static func InitializeSer( serObject: SerEntity,
        completed: @escaping ( Result<(SerHeader, SerHeaderDescription), Error> ) -> Void ) {
        do {
            _serReader = try FileSer.init(serObject: serObject)
            try _serReader?.readHeader()
            _serHeader = _serReader?.Head
            _headerDescription = _serReader?.getHeaderDescription()
            _sourceDType = .SerFile
            completed(.success( (_serHeader, _headerDescription) ))
        }
        catch { completed(.failure(error)) }
        
    }
    
    static func LoadSerImage(completed: @escaping ( Result<CGImage, Error> ) -> Void ) {
        do {
            guard let serCGData = try _serReader?.GetHighDefCGImageFromSer() else { throw FileSERErrors.DataReadFail }
            completed(.success( serCGData ))
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
    static func getHeader() -> SerHeader? {
        return _serHeader
    }
    static func getHeaderDescription() -> SerHeaderDescription {
        return _headerDescription
    }
    
    static func processImage(workingImage: CGImage?,
                             completed: @escaping (Result< CGImage, Error> ) -> Void) {
        guard let inputImage = workingImage else {
            completed(.failure( ModelIOErrors.MissingSourceImage ))
            return
        }
        // Model output call
        do {
            switch _sourceDType {
            case .Images:
                guard let (_mlMatrixOutput, _cgModelOutput) = try getCGActivations(image: inputImage, modelType: _currentModel)  as? (Matrix, CGImage) else { throw ModelIOErrors.GetActivationsError }
                    completed(.success( _cgModelOutput )) //MARK: unsafe
                return
            case .SerFile:
                guard let (_mlMatrixOutput, _cgModelOutput) = try getCGActivations(image: inputImage, modelType: _currentModel) as? (Matrix, CGImage) else { throw ModelIOErrors.GetActivationsError }
                completed(.success( _cgModelOutput )) //MARK: unsafe
                return
            case .EmiFile:
                completed(.failure(ModelIOErrors.NotConfigured   ))
            }
            
        } catch let error { completed(.failure( error )) }
    }
        
    static func setCurrentModel( _ to: MLModels ) {
        _currentModel = to
    }
    
    static func getCurrentModel() -> MLModels {
        return _currentModel
    }
}

