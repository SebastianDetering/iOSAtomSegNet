//
//  FileRead.swift
//  SwiftSER
//
//  Created by Sebastian Detering on 19.2.21.

import Foundation
import Accelerate

// reading class, will keep track of byte offsets, has various data fetching methods.
// Apple's fread doesn't have offsets and type specific data retreiving functions; so this is what I made instead (lots of hardcoding I wanted to avoid), this primarily makes the transition from python more doable.

class fRead {
    var off : Int
    var data : Data?
    var closed : Bool = true
    
    init( data : Data? )  {
        self.off = 1
    
        self.data = data
        self.closed = false
    }
    
    func close() throws {
        do {
        if !closed {
            if data != nil {
            data!.removeAll()
            closed = true
            off = 0
            }
            else { throw FileReadError.UninitializedFileRead}
        }
        else { throw FileReadError.AlreadyClosed }
        }
        catch let error as NSError { throw error}
    }
    
    func resetOffsetToZero() {
        off = 0
    }
    
    func setOffset( _ to : Int ) {
        self.off = to
    }
    func moveOffset( _ by : Int) {
        self.off += by
    }
    private func getOffset() -> Int {
        return off
    }
    // mimics np.fromfile
    
    // trying to use generics.  This T as binary Integer conformance force is very cool, I want it to be allowed to be BinaryFloat too.. lets see
    //
    func fromfileBI<T : BinaryInteger>(count : Int = 1) throws -> [T]  {
        let byteSize = MemoryLayout<T>.stride
        var swiftTypeOut : [T] = []
        if data == nil {
            throw FileReadError.UninitializedFileRead
        }
        do {
        if count > 1 {
            swiftTypeOut = [T].init(repeating: 0, count: count)
            for i in 0...count-1 {
                swiftTypeOut[i] = data!.subdata(in: off + i * byteSize..<off + (i + 1) * byteSize ).withUnsafeBytes{ $0.load(as: T.self )}
            }
            off += count * byteSize
        }
        else if count == 1 {
            swiftTypeOut =  [ data!.subdata(in: off..<(off+1) * byteSize ).withUnsafeBytes{ $0.load(as: T.self )} ]
            off += byteSize
        }
        else if count == 0 {
            return []
        } else if count < 0 {
            throw FileReadError.NegativeCount
        }
        return swiftTypeOut
        }
        catch let error as NSError {
            throw error
        }
    }
    
    func fromfileBF<T: BinaryFloatingPoint>(count : Int = 1) throws -> [T] {
        let byteSize = MemoryLayout<T>.stride
        var swiftTypeOut : [T] = []
        if data == nil {
            throw FileReadError.UninitializedFileRead
        }
        do {
        if count > 1 {
            swiftTypeOut = [T].init(repeating: 0, count: count)
            for i in 0...count-1 {
                swiftTypeOut[i] = data!.subdata(in: off + i * byteSize..<off + (i + 1) * byteSize ).withUnsafeBytes{ $0.load(as: T.self )}
            }
            off += count * byteSize
        }
        else if count == 1 {
            swiftTypeOut =  [ data!.subdata(in: off..<(off+1) * byteSize ).withUnsafeBytes{ $0.load(as: T.self )} ]
            off += byteSize
        }
        else if count == 0 {
            return []
        } else if count < 0 {
            throw FileReadError.NegativeCount
        }
        return swiftTypeOut
        }
        catch let error as NSError {
            throw error
        }
        
    }
}
