import Foundation

enum ModelIOErrors : Error {
    case OversizedImageError
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
}

enum ForImageFormatError : Error {
    case MaxNotFound
    case MinNotFound
    case MinMaxValuesDoNotExist
    case FormatFail
}

enum FileReadError : Error {
    case WrongBinaryType
    case OutofBounds
    case AlreadyClosed
    case UnknownType
    case NegativeCount
    case UninitializedFileRead
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
