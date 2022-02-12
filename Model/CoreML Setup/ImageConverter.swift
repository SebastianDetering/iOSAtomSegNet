//
//  ImageProcesser.swift
//  ArrayImageViewer
//
//  Created by sebi d on 8/15/21.
//

import CoreGraphics
import Foundation
import CoreML

//import MLCompute

extension CGImage {
    func pixelData() -> [UInt8]? {
        let dataSize = self.width * self.height
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData,
                                width: Int(self.width),
                                height: Int(self.height),
                                bitsPerComponent: 8,
                                bytesPerRow:  Int(self.width) * MemoryLayout<UInt8>.stride,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        context?.draw(self, in: CGRect(x: 0, y: 0, width: self.width, height: self.height))

        return pixelData
    }
    
    func hDefPixelData() -> [Float32]? {
        let dataSize = self.width * self.height
        var pixelData = [Float32](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: &pixelData,
                                width: Int(self.width),
                                height: Int(self.height),
                                bitsPerComponent: 32,
                                bytesPerRow:  Int(self.width) * MemoryLayout<Float32>.stride,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        context?.draw(self, in: CGRect(x: 0, y: 0, width: self.width, height: self.height))

        return pixelData
    }
 }


struct ImageConverter {
    
    static func hDefPixelBuffer( forImage image: CGImage, imgArrayShape: [NSNumber] = [1,1,512,512] ) throws -> MLMultiArray? {
        guard let imageArray = image.hDefPixelData() else { throw FileSERErrors.CGConversionError }
        
        var pixelBuffer: MLMultiArray
        do {
            pixelBuffer = try MLMultiArray( shape: imgArrayShape, dataType: .float32)
            
            for i in 0..<imageArray.count {
                pixelBuffer[i] = NSNumber( value: imageArray[i])
            }
        } catch let error as MLModelError { throw error }
        return pixelBuffer
    }
    
    static func arr2MLPixelBuffer(_ fromArr: [Float32], shape: [NSNumber] = [1,1,512,512]) throws -> MLMultiArray? {
        var pixelBuffer: MLMultiArray
        do {
            pixelBuffer = try MLMultiArray( shape: shape, dataType: .float32)
            
            for i in 0..<fromArr.count {
                pixelBuffer[i] = NSNumber( value: fromArr[i])
            }
        } catch let error as MLModelError { throw error }
        return pixelBuffer
    }
    
    static func pixelBuffer( forImage image: CGImage, imgArrayShape : [NSNumber] = [1,1, 512, 512]) throws  -> MLMultiArray?  {
     
        let imageArray = image.pixelData()!
        
        let min = imageArray.min()!
        let max = imageArray.max()!
        
        var float32Array = imageArray.map { Float32( $0 -  min ) / Float32( max ) }
        
        let pointer = UnsafeMutablePointer<Float32>.allocate(capacity : float32Array.count )
        pointer.initialize( from : &float32Array, count : float32Array.count  )
        
        var pixelBuffer : MLMultiArray
        do {
            pixelBuffer = try MLMultiArray( shape : imgArrayShape, dataType: .float32 )
            
            for i in 0..<float32Array.count {
                pixelBuffer[i] = NSNumber( value : float32Array[i] )
            }
         
        } catch let error as MLModelError { throw error }
        
        return pixelBuffer
    }
    
    static func pixelBuffer( imageArray : [UInt8], imgArrayShape : [NSNumber] = [1, 1, 512, 512] ) throws -> MLMultiArray {

        let min = imageArray.min()!
        let max = imageArray.max()!
        
        var float32Array = imageArray.map { Float32( $0 -  min ) / Float32( max ) }
        
        let pointer = UnsafeMutablePointer<Float32>.allocate(capacity : float32Array.count )
        pointer.initialize( from : &float32Array, count : float32Array.count  )
        
        var pixelBuffer : MLMultiArray
        
        do {
            pixelBuffer = try MLMultiArray( shape : imgArrayShape, dataType: .float32 )
    
            //can't use map here.
            for i in 0..<float32Array.count {
                pixelBuffer[i] = NSNumber( value : float32Array[i] )
            }
         
        } catch let error as MLModelError { throw error }
        
        return pixelBuffer
    }
}


