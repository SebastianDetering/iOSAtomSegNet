import SwiftUI
import CoreGraphics
import CoreML

typealias float4 = SIMD4<Float>

let directory = "/Users/sebi/Dev/Ser-PythonSwift-Port/Tests-Files/Supporting_Files/"

class SerBitmap {
    // will hold info regarding Ser image(s) and the Bitmap itself ready to be drawn to Apple devices in desired format.f
    // CGImage is a bitmap only, and is the only current format.
    var image : Image?
    var imageName : String?
    var inputCGImage      : CGImage?
    var fileSer_test : FileSer?

    
    init(imageName : String) {
        self.imageName = imageName
        guard let pngProvider = CGDataProvider(url: Bundle.main.url(forResource: imageName, withExtension: "png")! as CFURL) else { print("png provider error")
            return}
        self.inputCGImage = CGImage(pngDataProviderSource: pngProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        
    }
    
    func GetCGImage(index : Int = 0) throws {
 
        let width = 512
        let height = 512 // hardcoded for model input size
        let count = width * height
            var arrayDataforImage : [UInt8]? = nil
            
            do {

                let uInt8DataPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: count)
                uInt8DataPointer.initialize(from: &arrayDataforImage!, count: count)
                let bitsPerComponent = 8
                let bytesPerPixel = 1

                let bitsPerPixel = bitsPerComponent * bytesPerPixel
                let bytesPerRow: Int = width * bytesPerPixel;
                    
                let flatCFData = CFDataCreate(nil, uInt8DataPointer, count * bytesPerPixel )
                let cgDataProvider = CGDataProvider.init(data: flatCFData! )
                let deviceColorSpace = CGColorSpaceCreateDeviceGray()

//                arrayDataforImage = self.inputCGImage?
                let input  = try ImageConverter.pixelBuffer( imageArray: arrayDataforImage! )
                
                let model  = try segmentationNetwork()
                
                let output = try model.getActivations( input )
                                
                let serImage = CGImage.init(width: width, height: height,
                                            bitsPerComponent: bitsPerComponent,   // 1 byte for UInt8 * 8 bits per byte
                                            bitsPerPixel: bitsPerPixel,
                                            bytesPerRow: bytesPerRow,
                                            space: deviceColorSpace,
                                            bitmapInfo: [],
                                            provider: cgDataProvider!,
                                            decode: nil,           // No remapping
                                            shouldInterpolate: true,
                                            intent: .defaultIntent)

                self.image = Image.init(serImage!, scale : 1.0, orientation : .up, label: Text("PlaceHolder") )
            } catch let error { throw error }
        
    }
    
    func GetCGImageFromSer(index : Int = 0, serFile: String) throws {
        if fileSer_test == nil {
            throw "fileSer_test improperly initialized in SerImage getter"
        }
        fileSer_test?.filename = serFile

        do {
        let header = try self.fileSer_test!.readHeader(verbose : true)
        if header == nil {
            throw FileSERErrors.UninitializedHead
        }
  
            let FirstMeta : SerMeta = try fileSer_test!.getMetaType(index: 0)
            let np_Type = FirstMeta.DataType

            var arrayDataforImage : [UInt8]? = nil
            switch np_Type {
            case 1:
                // second tuple element will be null in all int cases and flipped for floats.
                let dataset : ([UInt8]?, [Float16]?, SerMeta) = try fileSer_test!.getDataset(index: 0,verbose: true)
                arrayDataforImage = try formatArrayDataforImage(dataSet: dataset.0 )
            case 2:
                let dataset : ([UInt16]?, [Float16]?, SerMeta) = try fileSer_test!.getDataset(index: 0,verbose: true)
                arrayDataforImage = try formatArrayDataforImage(dataSet: dataset.0 )
            case 3:
                let dataset : ([UInt32]?, [Float16]?, SerMeta) = try fileSer_test!.getDataset(index: 0,verbose: true)
                arrayDataforImage = try formatArrayDataforImage(dataSet: dataset.0 )
            case 4:
                let dataset : ([Int8]?, [Float16]?, SerMeta) = try fileSer_test!.getDataset(index: 0,verbose: true)
                arrayDataforImage = try formatArrayDataforImage(dataSet: dataset.0 )
            case 5:
                let dataset : ([Int16]?, [Float16]?, SerMeta) = try fileSer_test!.getDataset(index: 0,verbose: true)
                arrayDataforImage = try formatArrayDataforImage(dataSet: dataset.0 )
            case 6:
                let dataset : ([Int32]?, [Float16]?, SerMeta) = try fileSer_test!.getDataset(index: 0,verbose: true)
                arrayDataforImage = try formatArrayDataforImage(dataSet: dataset.0 )
            case 7:
                let dataset : ([UInt8]?, [Float32]?, SerMeta) = try fileSer_test!.getDataset(index: 0,verbose: true)
                arrayDataforImage = try formatArrayDataforImage(dataSet: dataset.1 )
            case 8:
                let dataset : ([UInt8]?, [Float64]?, SerMeta) = try fileSer_test!.getDataset(index: 0,verbose: true)
                arrayDataforImage = try formatArrayDataforImage(dataSet: dataset.1 )
            case 9:
                throw FileSERErrors.ComplexNotProgrammedYet
            case 10:
                throw FileSERErrors.ComplexNotProgrammedYet
            default :
                throw "Not a ser dictionary type"
            }
        
        // meta entries will be structs in the future.
//        guard let arrShape : [Int] = fileSer_test.metaArray![0]["ArrayShape"] as? [Int] else { fatalError("meta no  initialized.")}
        let arrShape : [Int] = fileSer_test!.MetaArray[0].ArrayShape
        let width = arrShape[0]
        let height :  Int? = arrShape[1]
            if height == nil {
                throw "This data is 1D"
            }
        let count = width * height!
            if count == 0 {
                throw "width * height 0, no image will be made."
            }
        // I need to get data into bytes, move into a pointer of CFData type, then initialize CGDataProvider.
    // Image is Grayscale, each layer needs to be unsigned Int8 0-255
        let uInt8DataPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: count)
        uInt8DataPointer.initialize(from: &arrayDataforImage!, count: count)
        let bitsPerComponent = 8
        let bytesPerPixel = 1

        let bitsPerPixel = bitsPerComponent * bytesPerPixel
        let bytesPerRow: Int = width * bytesPerPixel;
            
        let flatCFData = CFDataCreate(nil, uInt8DataPointer, count * bytesPerPixel )
        let cgDataProvider = CGDataProvider.init(data: flatCFData! )
        let deviceColorSpace = CGColorSpaceCreateDeviceGray()

        let serImage = CGImage.init(width: width, height: height!,
                                    bitsPerComponent: bitsPerComponent,   // 16 bytes for UInt16 * 8 bits per byte
                                    bitsPerPixel: bitsPerPixel,
                                    bytesPerRow: bytesPerRow,
                                    space: deviceColorSpace,
                                    bitmapInfo: [],
                                    provider: cgDataProvider!,
                                    decode: nil,           // No remapping
                                    shouldInterpolate: true,
                                    intent: .defaultIntent)

        //https://stackoverflow.com/questions/51372245/swift-convert-byte-array-into-ciimage

        self.image = Image.init(serImage!, scale : 1.0, orientation : .up, label: Text("PlaceHolder") )
        uInt8DataPointer.deallocate()
            
            do {
                let input  = try ImageConverter.pixelBuffer( imageArray: arrayDataforImage! )
                
                //let output = try model.getActivations( input )
                
                let pointer = UnsafeMutablePointer<Float32>( OpaquePointer( input.dataPointer ) )
                var linearOffset = 0
                
                let key = [ 0, 0, 30, 30] as [NSNumber]
                for (dimension, stride) in zip(key, input.strides) {
                    linearOffset += dimension.intValue * stride.intValue
                }
                assert(pointer[linearOffset] == input[key].floatValue)
                
                var floatArray = [Float32].init(repeating: 0, count: count )
                linearOffset = 0
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

                let serImage = CGImage.init(width: width, height: height!,
                                            bitsPerComponent: bitsPerComponent,   // 1 byte for UInt8 * 8 bits per byte
                                            bitsPerPixel: bitsPerPixel,
                                            bytesPerRow: bytesPerRow,
                                            space: deviceColorSpace,
                                            bitmapInfo: [],
                                            provider: cgDataProvider!,
                                            decode: nil,           // No remapping
                                            shouldInterpolate: true,
                                            intent: .defaultIntent)
                
                self.image = Image.init(serImage!, scale : 1.0, orientation : .up, label: Text("PlaceHolder") )
            } catch let error { throw error }
        
        

        }
        
        catch let error as NSError { throw error }
    }
}


