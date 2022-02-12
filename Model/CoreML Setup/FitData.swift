import Foundation

// the function which will take a dataset and bring its values into the 0-255 range for drawing to an image.

// This stack overflow user suggests extending the type you want to conform to a protocol (see ––– extension String : SomeProtocol {} ) in example code.
//https://stackoverflow.com/questions/37216240/generic-function-taking-a-type-name-in-swift

 // Got some help from Eric Lippert https://stackoverflow.com/users/88656/eric-lippert

final class ArrayFormatter {
static func arrayForMLModel<Element>(dataSet: [Element]) throws -> [Float32]
where Element: BinaryInteger {
    do {
    return try arrayForMLModel(dataSet: dataSet.map(Float.init))
    } catch { throw error }
}

static func arrayForMLModel<Element>(dataSet: [Element]) throws -> [Float32]
where Element: BinaryFloatingPoint {
    guard let max = dataSet.max() else { throw ForImageFormatError.MaxNotFound }
    guard let min = dataSet.min() else { throw ForImageFormatError.MinNotFound }
    if abs( min ) <= max {
        if min >= 0  {
            let balancer = max - min
        return dataSet.map { Float32( ($0 - min) / balancer ) }
        }
        else if min < 0 {
            let balancer = max + abs(min)
            return dataSet.map { Float32( ( $0 - min ) / balancer ) }
        }
    }
    else if abs( min ) > max {
        if min >= 0  {
            let balancer = max + min
            return dataSet.map { Float32( $0  / (  balancer )) }
        }
        else if min < 0 {
            let balancer = max + abs(min)
            return dataSet.map { Float32(( $0 - min ) / balancer ) }
        }
    }
    else { throw ForImageFormatError.FormatFail }
    // dont see how it's possible to reach this
    return []
}

static func arrayForImage<Element>(dataSet: [Element]?) throws -> [UInt8]
where Element: BinaryInteger  // <=== Note different `where` clause
{
    if dataSet == nil {
        throw "Nil dataset entered"
    }
    // Since this creates a [Float] it will call the other function
    do {
        return try arrayForImage(dataSet: dataSet!.map(Float.init))
    }
    catch let error as ForImageFormatError { throw error }
}

static func arrayForImage<Element>(dataSet: [Element]?) throws -> [UInt8] where Element: BinaryFloatingPoint {
    if dataSet == nil {
        throw "Nil dataset entered"
    }
    guard let max = dataSet!.max() else { throw ForImageFormatError.MaxNotFound }
    guard let min = dataSet!.min() else { throw ForImageFormatError.MinNotFound }

    // Note this is a little dangerous since it will crash if
    // " ($0 - min) / max " isn't in the range 0 - 1. I'd probably add
    // assertions at least.
    // so in order to solve this  I need to assert that |min| < |max|, or use a different formula if |min| > |max|
    if abs( min ) <= max {
        if min >= 0  {
            let balancer = max - min
        return dataSet!.map { UInt8(255 * ($0 - min) / balancer ) }
        }
        else if min < 0 {
            let balancer = max + abs(min)
            return dataSet!.map { UInt8(255 * ( $0 - min ) / balancer ) }
        }
    }
    else if abs( min ) > max {
        if min >= 0  {
            let balancer = max + min
            return dataSet!.map { UInt8(255 * $0  / (  balancer )) }
        }
        else if min < 0 {
            let balancer = max + abs(min)
            return dataSet!.map { UInt8(255 * ( $0 - min ) / balancer ) }
        }
    }
    else { throw ForImageFormatError.FormatFail }
    // dont see how it's possible to reach this
    return []
}
}

//https://stackoverflow.com/questions/67205713/parallel-array-elements-assignment-causes-crash-in-swift  if you do stuff parallel with pointers again.
