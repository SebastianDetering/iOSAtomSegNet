
import SwiftUI
import CoreGraphics
import LASwift
import CoreML

// The Image Processing Lifecycle is coded here.
func getCGActivations(image: UIImage, modelType: MLModels) throws -> (MLMultiArray, CGImage)? {
    let imageArrayData = getRGBAArrays(uiImage: image)
    let imageWidth  = image.size.width
    let imageHeight = image.size.height
    var rChannelData = imageArrayData[0]
    
    // determine im2pad parameters from source image dimensions.
    var multiArrayShape : [NSNumber] = [1, 1, 512, 512]
    var pad = true
    if imageWidth == 512 && imageHeight == 512 {
        pad = false
    } else if imageWidth == 1024 && imageHeight == 1024 {
        pad = false
    }
    // if dimensions not exact
    if pad == true {
        if imageWidth < 512 || imageHeight < 512 {
            // multiArrayShape remains same
        } else if imageWidth < 1024  || imageHeight < 1024 {
            // one of the dimensions is greater than 512, and so we must change im2pad size to 1024x1024
            multiArrayShape = [1, 1, 1024, 1024]
        } else {
            // one of the dimensions is greater than max model input size, so throw error.
            throw ModelIOErrors.OversizedImageError
        }
        
        var padding = zeros( Int(truncating: multiArrayShape[2]), Int(truncating: multiArrayShape[3]) )
        let imageMat = im2RGBA(uiImage: image)[0] // red component Matrix
        padding[0...Int(imageHeight)-1, 0...Int(imageWidth)-1] = imageMat // set the portion of the zeros matrix to the image matrix
        rChannelData = padding.flat.map { UInt8( $0 )}
    }
    
    do {
        let model = try segmentationNetwork()
        model.setCurrentModel(modelType)
        var multiArray = try MLMultiArray.init(shape: multiArrayShape, dataType: .float32)
        multiArray = try ImageConverter.pixelBuffer(imageArray: rChannelData)
        var (mlArrayOutput, cgOut) = try model.getCGImageActivations(multiArray)
        if pad {
            cgOut = cgOut.cropping(to: CGRect(x: 0, y: 0, width: Int(imageWidth), height: Int(imageHeight)))!
        }
        return (mlArrayOutput, cgOut)

    } catch {
        print(error)
    }
    return nil
}
