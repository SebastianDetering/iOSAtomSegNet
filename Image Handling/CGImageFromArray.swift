import CoreGraphics

func getCGImageFromArray(_ of: [UInt8], width: Int, height: Int) -> CGImage {
    
    
    let count = width * height
    let uInt8DataPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: count)
    uInt8DataPointer.initialize(from: of, count: count)
    let bitsPerComponent = 8
    let bytesPerPixel = 1
    
    let bitsPerPixel = bitsPerComponent * bytesPerPixel
    let bytesPerRow: Int = width * bytesPerPixel;
    
    let imageCFData = CFDataCreate(nil, uInt8DataPointer, count * bytesPerPixel )
    let cgDataProvider = CGDataProvider.init(data: imageCFData! )
    let deviceColorSpace = CGColorSpaceCreateDeviceGray()
    
    guard let CGImage = CGImage.init(width: width, height: height,
                               bitsPerComponent: bitsPerComponent,   // 1 byte for UInt8 * 8 bits per byte
                               bitsPerPixel: bitsPerPixel,
                               bytesPerRow: bytesPerRow,
                               space: deviceColorSpace,
                               bitmapInfo: [],
                               provider: cgDataProvider!,
                               decode: nil,           // No remapping
                               shouldInterpolate: true,
                               intent: .defaultIntent) else { fatalError("couldn't get CGImage from array")}
    
    return CGImage
    
}
