//
//  main.swift
//  CoreML_Image_Network-test
//
//  Created by sebi d on 9/19/21.
//

import SwiftUI
import CoreGraphics
import LASwift

func im2RGBA(uiImage: UIImage) -> [Matrix] {
    let startTime = CFAbsoluteTimeGetCurrent()
    print("Getting matrix data from image, image dimensions\(uiImage.size.width) x \(uiImage.size.height)")
    guard let image: CGImage = uiImage.cgImage else { fatalError("Initialization of CGImage from NSImage failed.")} //MARK: throw
    
    let width = image.width
    let height = image.height
    let colorspace = CGColorSpaceCreateDeviceRGB()
    let bytesPerRow = 4 * width
    let bitsPerComponent = 8
    var pixels = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 4 )

    let context = CGContext.init(data: pixels,
                                 width: width,
                                 height: height,
                                 bitsPerComponent: bitsPerComponent,
                                 bytesPerRow: bytesPerRow,
                                 space: colorspace,
                                 bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)

    context?.draw(image, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
    
    var alpha = zeros(height, width)
    var red   = zeros(height, width)
    var green = zeros(height, width)
    var blue  = zeros(height, width)

    for y in 0..<height {
        for x in 0..<width {
        red[y, x]    = Double(pixels.pointee)
        pixels = pixels + 1
        green[y, x] = Double(pixels.pointee)
        pixels = pixels + 1
        blue[y, x]    = Double(pixels.pointee)
        pixels = pixels + 1
        alpha[y, x]     = Double(pixels.pointee)
        pixels = pixels + 1
      }
    }
    
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("Time elapsed \(String(format : "%0.5f", timeElapsed)) seconds")
    print()
    return [red, green, blue, alpha]
}

func getRGBAArrays(uiImage: UIImage) -> [[UInt8]] {
    let startTime = CFAbsoluteTimeGetCurrent()
    print("Getting array data from image, image dimensions\(uiImage.size.width) x \(uiImage.size.height)")
    guard let image: CGImage = uiImage.cgImage else { fatalError("Initialization of CGImage from NSImage failed.")}
    
    let width = image.width
    let height = image.height
    let colorspace = CGColorSpaceCreateDeviceRGB()
    let bytesPerRow = 4 * width
    let bitsPerComponent = 8
    var pixels = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 4 )

    let context = CGContext.init(data: pixels,
                                 width: width,
                                 height: height,
                                 bitsPerComponent: bitsPerComponent,
                                 bytesPerRow: bytesPerRow,
                                 space: colorspace,
                                 bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)

    context?.draw(image, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
    
    var alpha = [UInt8].init(repeating: 0, count: width * height)
    var red   = [UInt8].init(repeating: 0, count: width * height)
    var green = [UInt8].init(repeating: 0, count: width * height)
    var blue  = [UInt8].init(repeating: 0, count: width * height)

    let test_val = pixels.pointee
    print(test_val)
    print( pixels.pointee)
    var linearOffset = 0
    for _ in 0..<width {
        for _ in 0..<height {
        red[linearOffset]    = pixels.pointee
        pixels = pixels + 1
        green[linearOffset]      = pixels.pointee
        pixels = pixels + 1
        blue[linearOffset]    = pixels.pointee
        pixels = pixels + 1
        alpha[linearOffset]     = pixels.pointee
            pixels = pixels + 1
        linearOffset += 1
      }
    }
    
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("Time elapsed \(String(format : "%0.5f", timeElapsed)) seconds")
    print()
    return [red, green, blue, alpha]
}
