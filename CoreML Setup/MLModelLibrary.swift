import CoreML

// strategy pattern

enum MLModels: String {
    case gaussianMask = "Gaussian Mask"
    case circularMask = "Circular Mask"
    case denoise      = "Denoise"
    case denoise_bgremoval = "Denoise and Background Removal"
    case denoise_bgremoval_superres = "Denoise and Background Removal and Super Resolution"
}

enum hResMLModels: String {
    case gaussianMask_1024 = "Gaussian Mask"
    case circularMask_1024 = "Circular Mask"
    case denoise_1024     = "Denoise"
    case denoise_bgremoval_1024 = "Denoise and Background Removal"
    case denoise_bgremoval_superres_1024 = "Denoise and Background Removal and Super Resolution"
}

let applicationMLModelLibrary = MLModelLibrary()

class MLModelLibrary {
    
    private var _library : [ MLModels : Any ] = [:]
    private var _hResLibrary : [hResMLModels : Any] = [:]
    
    init() {
        fillLibrary()
    }
    
    func fillLibrary() {
            do {
            // '&' in file name replaced with '_'
            try _library.updateValue( gaussianMask(), forKey: .gaussianMask)
            try _library.updateValue( circularMask(), forKey: .circularMask)
            try _library.updateValue( denoise(), forKey: .denoise)
            try _library.updateValue( denoise_bgremoval(), forKey: .denoise_bgremoval)
            try _library.updateValue( denoise_bgremoval_superres(), forKey: .denoise_bgremoval_superres)
            // 1024 x 1024 size
            try _hResLibrary.updateValue( gaussianMask_1024(), forKey: .gaussianMask_1024)
            } catch { fatalError("Something went wrong initializing the library of MLModels.") }
    }
    
    func getMLModel( model: MLModels) -> Any {
        return _library[model]
    }
    
}

class segmentationNetwork: ObservableObject {
    
    private var _modelType : MLModels = .gaussianMask
    private var _currentModel : Any
    
    init() throws {
        do {
            self._currentModel = applicationMLModelLibrary.getMLModel( model: _modelType )
        } catch let error as MLModelError { throw error }
    }
    
    func getCurrentModel() -> MLModels {
        return _modelType
    }
    
    func setCurrentModel(_ model: MLModels) {
        _modelType = model
        self._currentModel = applicationMLModelLibrary.getMLModel(model: _modelType)
    }
    
    private func _getModelOutput( _ input: MLMultiArray ) throws -> Any {
        var predictResults : Any
        do {
            //switch on each model type to help the compiler identify the model output layer.
            switch _modelType {
            case .gaussianMask:
                predictResults = try (_currentModel as! gaussianMask).prediction(input0: input)
            case .circularMask:
                predictResults = try (_currentModel as! circularMask).prediction(input0: input)
            case .denoise:
                predictResults = try (_currentModel as! denoise).prediction(input0: input)
            case .denoise_bgremoval:
                predictResults = try (_currentModel as! denoise_bgremoval).prediction(input0: input)
            case .denoise_bgremoval_superres:
                predictResults = try (_currentModel as! denoise_bgremoval_superres).prediction(input0: input)
            }
        } catch let error as MLModelError { throw error }
        
        return predictResults
        
    }
    
    func getActivations( _ of: MLMultiArray ) throws -> MLMultiArray {
        
        var output : MLMultiArray
        do {
            switch _modelType {
            case .gaussianMask:
                output = try (_getModelOutput( of ) as! gaussianMaskOutput)._324
            case .circularMask:
                output = try (_getModelOutput( of ) as! circularMaskOutput)._324
            case .denoise:
                output = try (_getModelOutput( of ) as! denoiseOutput)._324
            case .denoise_bgremoval:
                output = try (_getModelOutput( of ) as! denoise_bgremovalOutput)._324
            case .denoise_bgremoval_superres:
                output = try (_getModelOutput( of ) as! denoise_bgremoval_superresOutput)._324
            }
        } catch let error as MLModelError { throw error }
        
        return output
        
    }
    
    func getCGImageActivations( _ of: MLMultiArray ) throws -> (MLMultiArray, CGImage) {
        var mlArrayOutput = of
        do {
            mlArrayOutput = try self.getActivations(of)
        } catch { throw error }
                let width = 512
                let height = 512
                let count = width * height
            let pointer = UnsafeMutablePointer<Float32>( OpaquePointer( mlArrayOutput.dataPointer ) )

            
            var floatArray = [Float32].init(repeating: 0, count: count )
        
            for i in 0..<count {
                    floatArray[i] = pointer[i]
            }
        
            var processedImage = try formatArrayDataforImage(dataSet: floatArray )

            let uInt8DataPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: count)
            uInt8DataPointer.initialize(from: &processedImage, count: count)
            let bitsPerComponent = 8
            let bytesPerPixel = 1

            let bitsPerPixel = bitsPerComponent * bytesPerPixel
            let bytesPerRow: Int = width * bytesPerPixel;
                
            let flatCFData = CFDataCreate(nil, uInt8DataPointer, count * bytesPerPixel )
            let cgDataProvider = CGDataProvider.init(data: flatCFData! )
            let deviceColorSpace = CGColorSpaceCreateDeviceGray()
                            
            let outputCGImage = CGImage.init(width: width, height: height,
                                        bitsPerComponent: bitsPerComponent,   // 1 byte for UInt8 * 8 bits per byte
                                        bitsPerPixel: bitsPerPixel,
                                        bytesPerRow: bytesPerRow,
                                        space: deviceColorSpace,
                                        bitmapInfo: [],
                                        provider: cgDataProvider!,
                                        decode: nil,           // No remapping
                                        shouldInterpolate: true,
                                        intent: .defaultIntent)
                     
        return (mlArrayOutput, outputCGImage!)
        
    }
    
}
