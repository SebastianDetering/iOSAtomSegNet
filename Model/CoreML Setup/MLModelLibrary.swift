import CoreML
import LASwift
// strategy pattern

enum MLModels: String, CaseIterable {
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

func getHResModel(_ of: MLModels) -> hResMLModels {
    switch of {
    case .gaussianMask:
        return .gaussianMask_1024
    case .circularMask:
        return .circularMask_1024
    case .denoise:
        return .denoise_1024
    case .denoise_bgremoval:
        return .denoise_bgremoval_1024
    case .denoise_bgremoval_superres:
        return .denoise_bgremoval_superres_1024
    }
}

let applicationMLModelLibrary = MLModelLibrary()

class MLModelLibrary {
    // model loading is Memory intensive so I added a helper function to get memory and to be smarter about when to deallocate the models.
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
                try _hResLibrary.updateValue( gaussianMask_1024(),               forKey: .gaussianMask_1024)

            } catch { fatalError(error.localizedDescription) }
    }
    
    func getMLModel( model: MLModels) -> ( Any, Any ) {   // ( 512x512 model, 1024x1024 model )
        let hResModel = getHResModel( model )
        // caching all hResModels consumes too much memory.
        if !_hResLibrary.keys.contains( hResModel )  {
            _hResLibrary = [:]
            do {
            switch hResModel {
            case .gaussianMask_1024:
                try _hResLibrary.updateValue( gaussianMask_1024(),               forKey: .gaussianMask_1024)
            case .circularMask_1024:
                try _hResLibrary.updateValue( circularMask_1024(),               forKey: .circularMask_1024)
            case .denoise_1024:
                try _hResLibrary.updateValue( denoise_1024(),                    forKey: .denoise_1024)
            case .denoise_bgremoval_1024:
                try _hResLibrary.updateValue( denoise_bgremoval_1024(),          forKey: .denoise_bgremoval_1024)
            case .denoise_bgremoval_superres_1024:
                try _hResLibrary.updateValue( denoise_bgremoval_superres_1024(), forKey: .denoise_bgremoval_superres_1024)
            }} catch { print(error.localizedDescription)}
        }
        return ( _library[model], _hResLibrary[ hResModel ] )
    }
    
}

class segmentationNetwork: ObservableObject {
    
    private var _modelType : MLModels = .gaussianMask
    private var _currentModel : Any
    private var _currentHResModel : Any
    
    init() throws {
        do {
            ( self._currentModel, self._currentHResModel ) = applicationMLModelLibrary.getMLModel( model: _modelType )
        } catch let error as MLModelError { throw error }
    }
    
    func getCurrentModel() -> MLModels {
        report_memory()
        return _modelType
    }
    
    func setCurrentModel(_ model: MLModels) {
        report_memory()
        _modelType = model
        ( self._currentModel, self._currentHResModel )  = applicationMLModelLibrary.getMLModel(model: _modelType)
    }
    private func report_memory() {
        var info = mach_task_basic_info()
        let MACH_TASK_BASIC_INFO_COUNT = MemoryLayout<mach_task_basic_info>.stride/MemoryLayout<natural_t>.stride
        var count = mach_msg_type_number_t(MACH_TASK_BASIC_INFO_COUNT)

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: MACH_TASK_BASIC_INFO_COUNT) {
                task_info(mach_task_self_,
                          task_flavor_t(MACH_TASK_BASIC_INFO),
                          $0,
                          &count)
            }
        }

        if kerr == KERN_SUCCESS {
            print("Memory in use (in bytes): \(info.resident_size)")
        }
        else {
            print("Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
        }
    }
    
    private func _getModelOutput( _ input: MLMultiArray ) throws -> Any {
        var predictResults : Any

        if input.shape == [1, 1, 512, 512] {
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
            
        } else if input.shape == [1, 1, 1024, 1024] {
            do {
                //switch on each model type to help the compiler identify the model output layer.
                switch _modelType {
                case .gaussianMask:
                    predictResults = try (_currentHResModel as! gaussianMask_1024).prediction(input0: input)
                case .circularMask:
                    predictResults = try (_currentHResModel as! circularMask_1024).prediction(input0: input)
                case .denoise:
                    predictResults = try (_currentHResModel as! denoise_1024).prediction(input0: input)
                case .denoise_bgremoval:
                    predictResults = try (_currentHResModel as! denoise_bgremoval_1024).prediction(input0: input)
                case .denoise_bgremoval_superres:
                    predictResults = try (_currentHResModel as! denoise_bgremoval_superres_1024).prediction(input0: input)
                }
            } catch let error as MLModelError { throw error }
            
        } else { throw ModelIOErrors.PoorlyConfiguredMLMultiArrayInputShape }
        
        return predictResults
    }
    
    func getActivations( _ ofArray: MLMultiArray ) throws -> MLMultiArray {
        
        var output : MLMultiArray
        if ofArray.shape == [1, 1, 512, 512] {
        do {
            switch _modelType {
            case .gaussianMask:
                output = try (_getModelOutput( ofArray ) as! gaussianMaskOutput)._324
            case .circularMask:
                output = try (_getModelOutput( ofArray ) as! circularMaskOutput)._324
            case .denoise:
                output = try (_getModelOutput( ofArray ) as! denoiseOutput)._324
            case .denoise_bgremoval:
                output = try (_getModelOutput( ofArray ) as! denoise_bgremovalOutput)._324
            case .denoise_bgremoval_superres:
                output = try (_getModelOutput( ofArray ) as! denoise_bgremoval_superresOutput)._324
            }
        } catch let error as MLModelError { throw error }
        } else if ofArray.shape == [1, 1, 1024, 1024] {
            do {
                switch _modelType {
                case .gaussianMask:
                    output = try (_getModelOutput( ofArray ) as! gaussianMask_1024Output)._324
                case .circularMask:
                    output = try (_getModelOutput( ofArray ) as! circularMask_1024Output)._324
                case .denoise:
                    output = try (_getModelOutput( ofArray ) as! denoise_1024Output)._324
                case .denoise_bgremoval:
                    output = try (_getModelOutput( ofArray ) as! denoise_bgremoval_1024Output)._324
                case .denoise_bgremoval_superres:
                    output = try (_getModelOutput( ofArray ) as! denoise_bgremoval_superres_1024Output)._324
                }
            } catch let error as MLModelError { throw error }
        } else { throw ModelIOErrors.PoorlyConfiguredMLMultiArrayInputShape }
        
        return output
        
    }
    
    func getCGImageActivations( _ of: MLMultiArray, _ withShape: [NSNumber] ) throws -> (Matrix, MLMultiArray, CGImage) {
        var mlArrayOutput = of
        do {
            mlArrayOutput = try self.getActivations(of)
        } catch {
            throw error
        }
            let width = Int( truncating: withShape[2] )
            let height = Int(truncating:  withShape[3] )
            let count = width * height
            let pointer = UnsafeMutablePointer<Float32>( OpaquePointer( mlArrayOutput.dataPointer ) )
            
            var floatArray = [Float32].init(repeating: 0, count: count )
            var matrix     = zeros(width, height)
            
            var linOffset = 0
            for y in 0..<height {
                for x in 0..<width {
                    matrix[y, x]  = Double(pointer[ linOffset ])
                    floatArray[ linOffset ] = pointer[ linOffset ]
                    linOffset += 1
                }
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
                     
        return (matrix, mlArrayOutput, outputCGImage!)
        
    }
    
}
