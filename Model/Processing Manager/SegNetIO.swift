
import SwiftUI
import CoreGraphics
import LASwift
import CoreML

// The Image Processing Lifecycle is coded here.

func getFloat32Activations(hDefCGImage: CGImage, modelType: MLModels) throws -> (Matrix?, CGImage?) {
    guard let f32Data = hDefCGImage.hDefPixelData() else { throw FileSERErrors.CGConversionError }
    let imageWidth  = hDefCGImage.width
    let imageHeight = hDefCGImage.height
    var f32Padded   = f32Data
    
    // determine im2pad parameters from source image dimensions.
    var multiArrayShape : [NSNumber] = [ 1, 1, 512, 512 ]
    var pad = true
    if imageWidth == 512 && imageHeight == 512 {
        pad = false
    } else if imageWidth == 1024 && imageHeight == 1024 {
        pad = false
    }
    // if dimensions not exact
    if pad == true {
        if imageWidth < 512 && imageHeight < 512 {
            // multiArrayShape remains same
        } else if imageWidth < 1024  && imageHeight < 1024 {
            // one of the dimensions is greater than 512, and so we must change im2pad size to 1024x1024
            multiArrayShape = [1, 1, 1024, 1024]
        } else {
            // one of the dimensions is greater than max model input size, so throw error.
            throw ModelIOErrors.OversizedImageError
        }
        
        var padding = zeros( Int(truncating: multiArrayShape[2]), Int(truncating: multiArrayShape[3]) )
        let imageMat = f32im2Mat(cgImage: hDefCGImage)
        padding[0...Int(imageHeight)-1, 0...Int(imageWidth)-1] = imageMat // set the portion of the zeros matrix to the image matrix
        f32Padded = padding.flat.map { Float32( $0 ) }
    }
    
    do {
        SegmentationNetwork.setCurrentModel(modelType, hResDesired: (multiArrayShape == [1,1,1024,1024]))
        let multiArray = try ImageConverter.arr2MLPixelBuffer(f32Padded, shape: multiArrayShape)!
        var (matrix, mlArrayOutput, cgOut) = try SegmentationNetwork.getCGImageActivations(multiArray, multiArrayShape)
        if pad {
            cgOut = cgOut.cropping(to: CGRect(x: 0, y: 0, width: Int(imageWidth), height: Int(imageHeight)))!
        }
        let matrixOutput = matrix[0...Int(imageHeight)-1, 0...Int(imageWidth)-1]
        return (matrixOutput, cgOut)

    } catch {
        throw error
    }
}

func getCGActivations(image: CGImage, modelType: MLModels) throws -> (Matrix?, CGImage?) {
    guard let imageArrayData = image.pixelData() else { throw "CGImage not converted to UInt8 array" }
    let imageWidth  = image.width
    let imageHeight = image.height
    var rChannelData = imageArrayData
    
    // determine im2pad parameters from source image dimensions.
    var multiArrayShape : [NSNumber] = [ 1, 1, 512, 512 ]
    var pad = true
    if imageWidth == 512 && imageHeight == 512 {
        pad = false
    } else if imageWidth == 1024 && imageHeight == 1024 {
        pad = false
        multiArrayShape = [1, 1, 1024, 1024]
    }
    // if dimensions not exact
    if pad == true {
        if imageWidth < 512 && imageHeight < 512 {
            // multiArrayShape remains same
        } else if imageWidth < 1024  && imageHeight < 1024 {
            // one of the dimensions is greater than 512, and so we must change im2pad size to 1024x1024
            multiArrayShape = [1, 1, 1024, 1024]
        } else {
            // one of the dimensions is greater than max model input size, so throw error.
            throw ModelIOErrors.OversizedImageError
        }
        
        var padding = zeros( Int(truncating: multiArrayShape[2]), Int(truncating: multiArrayShape[3]) )
        let imageMat = im2RGBA(cgImage: image)[0] // red component Matrix
        padding[0...Int(imageHeight)-1, 0...Int(imageWidth)-1] = imageMat // set the portion of the zeros matrix to the image matrix
        rChannelData = padding.flat.map { UInt8( $0 ) } // override array data with padded version
    }
    
    do {
        SegmentationNetwork.setCurrentModel(modelType, hResDesired: (multiArrayShape == [1,1,1024,1024]) )
        var multiArray = try MLMultiArray.init(shape: multiArrayShape, dataType: .float32)
        multiArray = try ImageConverter.pixelBuffer(imageArray: rChannelData, imgArrayShape: multiArrayShape)
        var (matrix, mlArrayOutput, cgOut) = try SegmentationNetwork.getCGImageActivations(multiArray, multiArrayShape)
        if pad {
            cgOut = cgOut.cropping(to: CGRect(x: 0, y: 0, width: Int(imageWidth), height: Int(imageHeight)))!
        }
        let matrixOutput = matrix[0...Int(imageHeight)-1, 0...Int(imageWidth)-1]
        return (matrixOutput, cgOut)

    } catch {
        throw error
    }
    return (nil, nil)
}

func getSegments(activations: MLMultiArray, cgActivations: CGImage ) {
    
}
