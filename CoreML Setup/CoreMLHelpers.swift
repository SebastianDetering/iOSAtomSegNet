import SwiftUI
import CoreGraphics
import CoreML

typealias float4 = SIMD4<Float>

let directory = "/Users/sebi/Dev/Ser-PythonSwift-Port/Tests-Files/Supporting_Files/"

class SerBitmap {
    // will hold info regarding Ser image(s) and the Bitmap itself ready to be drawn to Apple devices in desired format.
    // CGImage is a bitmap only, and is the only current coded format.
    var image : Image?
    var imageName : String?
    var inputCGImage      : CGImage?
    
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
}


