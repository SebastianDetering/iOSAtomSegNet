import Foundation

enum ModelIOErrors : Error {
    case MissingSourceImage
    case OversizedImageError
    case PoorlyConfiguredMLMultiArrayInputShape
    case GetActivationsError
    case NotConfigured
}

enum FileSERErrors : Error {
    case NotSERError
    case FileMissing
    case PoorDataRead
    case DataTypeUndefined
    case FilenameinputTypeUnidentified
    case UninitializedFileRead
    case UninitializedHead
    case DataReadFail
    case BetrayedLittleEndianExpectation
    case NegativeTotalNumberElements
    case NonIntegerIndex
    case DataTypeIDUndefined
    case ComplexNotProgrammedYet
    
    case Expected2DArrayGot1DArray
    case ZeroSizedDimension
    case CGConversionError
}

enum ForImageFormatError : Error {
    case MaxNotFound
    case MinNotFound
    case MinMaxValuesDoNotExist
    case FormatFail
}

enum FileReadError : Error {
    case ExpectedFloatBinaryType
    case ExpectedIntegerBinaryType
    case OutofBounds
    case AlreadyClosed
    case UnknownType
    case NegativeCount
    case UninitializedFileRead
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
