//
//  NumpyPortHelpers.swift
//  ArrayImageViewer
//
//  Created by sebi d on 7/10/21.
//

import Foundation

// Now switching between numpy string named types is handled entirely in here (with the exception of specifing manually what is conforming to BinaryInteger or BinaryFloatingPoint).
// initialize these structs with zeros for now...there may be a reason to make them optional and init with nil values later

let dictDataType : [Int : String ] = [ 1: "<u1", 2: "<u2", 3: "<u4", 4: "<i1", 5: "<i2", 6: "<i4", 7: "<f4", 8: "<f8", 9: "<c8",
                                       10: "<c16", 11 : "<i8" ] // these are identical to np.fromfile arguments... file-Read.swift will use this Int64 was added to end, to preserve how this looks in the other file.
    //dict : Information on data format.//

enum SerBinaryType {
    case BinaryFloatingPoint
    case BinaryInteger
    case NumpyComplex
    case Unknown
}

struct SerHeader {
    var SeriesID            : Int16 = 0
    var SeriesVersion       : Int16 = 0
    var DataTypeID          : Int32 = 0
    var TagTypeID           : Int32 = 0
    var TotalNumberElements : Int32 = 0
    var ValidNumberElements : Int32 = 0
    var OffsetArrayOffset   : Int   = 0 // whether raw val is 32 or 64 depends on offset_dtype, but I cast to Int anyways.
    var NumberDimensions    : Int32 = 0
    var Dimensions          : [SerDimensionDescriptor] = []
    var DataOffsetArray     : [Int] = [] // same condition as DataOffsetArray
    var TagOffsetArray      : [Int] = [] // ibid.
}

struct SerDimensionDescriptor {
    var DimensionSize       : Int32 = 0
    var CalibrationOffset   : Float64 = 0
    var CalibrationDelta    : Float64 = 0
    var CalibrationElement  : Int32 = 0
    var Description         : String = ""
    var Units               : [Int8] = []
}

struct SerTag {
    var TagTypeID   : Int32 = 0
}

struct SerMeta {
   var index : Int  = 0 // Not originally a meta item, but it may be useful for dealing with the meta items generally.
   var Calibration : [SerCalibrationDescriptor] = []
   var DataType    : Int16 = 0
   var ArrayShape  : [Int]  = [] // could be 2D or 1D
   var SerBinaryType : SerBinaryType = .Unknown         // My solution to the whole types being all over the place problem.
}

struct SerCalibrationDescriptor {
    var CalibrationOffset : Float64 = 0
    var CalibrationDelta  : Float64 = 0
    var CalibrationElement : Int32 = 0
}

func getGenericType( _ np_description : String) -> SerBinaryType {
    // could also be Int16 to avoid conversion to string, too late now
    switch np_description {
        case "<u2":
            return .BinaryInteger
        case "<u4":
            return .BinaryInteger
        case "<u8":
            return .BinaryInteger
        case "<i2":
            return .BinaryInteger
        case "<i4":
            return .BinaryInteger
        case "<i8":
            return .BinaryInteger
        case "<f2":
            return .BinaryFloatingPoint
        case "<f4":
            return .BinaryFloatingPoint
        case "<f8":
            return .BinaryFloatingPoint
        default :
            return .Unknown
    }
}

extension fRead {
    
    // when we expect some sort of integer.
    func npDataTypetoSwiftArrayBI<T>( dtype : String, count : Int = 1) throws -> [T] where T: BinaryInteger {
        do {
            switch dtype {  // same as _dictDataType[ dataTypeString ] as! String
            
            case "<u2":
                let outputArray : [T] = try fromfileBI(count : count )
                return outputArray
            case "<u4":
                let outputArray : [T] = try fromfileBI(count : count )
                return outputArray
            case "<u8":
                let outputArray : [T] = try fromfileBI(count : count )
                return outputArray
            case "<i2":
                let outputArray : [T] = try fromfileBI(count : count )
                return outputArray
            case "<i4":
                let outputArray : [T] = try fromfileBI(count : count )
                return outputArray
            case "<i8":
                let outputArray : [T] = try fromfileBI(count : count )
                return outputArray
            case "<f2":
                throw FileReadError.ExpectedIntegerBinaryType
            case "<f4":
                throw FileReadError.ExpectedIntegerBinaryType
            case "<f8":
                throw FileReadError.ExpectedIntegerBinaryType
            default :
                throw FileReadError.UnknownType
            }
        }
        catch let error as NSError { throw error }
    }
    func npDataTypetoSwiftArrayBF<T>( dtype : String, count : Int = 1) throws -> [T] where T: BinaryFloatingPoint {
        let errMsg = "Error in getting generic type to be \(dtype) during reading."
        do {
            switch dtype {  // same as _dictDataType[ dataTypeString ] as! String
            case "<u2":
                throw FileReadError.ExpectedFloatBinaryType
            case "<u4":
                throw FileReadError.ExpectedFloatBinaryType
            case "<u8":
                throw FileReadError.ExpectedFloatBinaryType
            case "<i2":
                throw FileReadError.ExpectedFloatBinaryType
            case "<i4":
                throw FileReadError.ExpectedFloatBinaryType
            case "<i8":
                throw FileReadError.ExpectedFloatBinaryType
            case "<f2":
                let outputArray : [T] = try fromfileBF(count : count )
                return outputArray
            case "<f4":
                let outputArray : [T] = try fromfileBF(count : count )
                return outputArray
            case "<f8":
                let outputArray : [T] = try fromfileBF(count : count )
                return outputArray
            default :
                throw FileReadError.UnknownType
            }
        }
       
    
    }
}

func makeInt<T>(dtype : String, raw : T) -> Int64? where T : BinaryInteger {
    switch dtype {
        case "<u2":
            return Int64(raw)
        case "<u4":
            return Int64(raw)
        case "<u8":
            return Int64(raw)
        case "<i2":
            return Int64(raw)
        case "<i4":
            return Int64(raw)
        case "<i8":
            return Int64(raw)
        default :
            print("makeInt got nowhere, the file data type string from numpy _dictDataType[ dataTypeString ] = " + dtype + "wasn't present in the switch statement.")
            return nil
    }
    
}

