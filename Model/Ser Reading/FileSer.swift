//
//  Ser-Classes-Structs.swift
//  Ser-Reader
//
//  Created by sebi d on 14.6.21.
//
// MARK: source  https://github.com/ercius/openNCEM/blob/e304d565870bdb32f76abc0adc0c937cf6947ebc/ncempy/io/ser.py
//
// MARK: Overview 07/06
// The reading will work on the testfile 2D data with datatype UInt16.  The problem is that I needed to make a slow Reading method (I know it's slow because it calls fromFile() over and over)
// That problem is then further problematic since fread has no data allocation implemented yet.
// Another problem that on further reflection I do not know whether it is a problem is; do I need to format the output of the 2D data as [[UInt16]] or is a continuous stream of values [UInt16] (same as python code what I want... then I don't need slowRead() but I will still need the data allocation fix.
// Finally, the data is so large that when it prints to the console it is invisible... small portions I can draw ( 10 rows for example.)
// I do not know how this will then be converted to image in Swift.
// 5:40 pm 07/06 It's outputting continuous list of correct types [ UInt16] for Scanning_0001


import Foundation
// MARK: for complex numbers, but I haven't coded this to work with complex yet.
import Accelerate
// For phone bundle
import UIKit
import SwiftUI

class FileSer {
    private let _dictByteOrder : [Int16: String] = [ 0x4949 : "little endian" ]
    // dict : Information on byte order.//
    private let _dictSeriesVersion : [Int16:String] = [0x0210: "< TIA 4.7.3", 0x0220: ">= TIA 4.7.3"]
        //dict : Information on file format version.//

    private let _dictDataTypeID : [Int32: String] = [0x4120: "1D datasets", 0x4122: "2D images"]
        //dict : Information on data type.//

    private let _dictTagTypeID : [Int32 : String] = [0x4152: "time only", 0x4142: "time and 2D position"]
        //dict : Information on tag type.//

    private let _dictDataType : [Int16 : String ] = [ 1: "<u1", 2: "<u2", 3: "<u4", 4: "<i1", 5: "<i2", 6: "<i4", 7: "<f4", 8: "<f8", 9: "<c8", 10: "<c16" ] // these are identical to np.fromfile arguments... file-Read.swift will use this
        //dict : Information on data format.//
    
    var head : [String: Any]? = nil
    var Head : SerHeader? = nil
    var headerDescription: SerHeaderDescription = SerHeaderDescription()
    
    var filename : Any? = nil
    
    private var _file_hdl : fRead? = nil

    var offset : Int = 0 
    
    private var _data : [Any]? = nil // the dynamic variable which will store raw data, in many types. Used in readHeader(), and practically every other function
    
    var offset_dtype : String?  = nil
    
    var metaArray : [[String:Any]]? = nil // this should be converted into a struct.  The indexing of meta values into an array will then be possible
    
    var MetaArray : [SerMeta] = []
    
    init(filename : Any?, verbose : Bool = false, mobileBundle : Bool = true ) throws {

        // necessary declarations, if something fails
        self._file_hdl = nil
            //  self.emi = nil
        self.head = nil

        self.offset_dtype = nil
        
        self.metaArray = nil
       
        // try opening the file
        do
        {
            // for mobile, use Assets catalogue
            if mobileBundle {
                
                if let asset = NSDataAsset(name: filename! as! String) {
                    self._file_hdl = fRead(data: asset.data)
                }
                else { print("File \(filename) not found in main bundle or NSDataAsset not initialized")}
            
            } else {
                // check filename type
                if filename is String {
                    guard let url = Bundle.main.url(forResource: (filename as! String), withExtension: ".ser" ) else { throw FileSERErrors.FileMissing }
                    self._file_hdl = fRead( data : try Data(contentsOf: url ))
                }
                else if filename is URL {
                    self._file_hdl = fRead( data : try Data(contentsOf : self.filename as! URL) )
                }
                else {
                    throw FileSERErrors.FilenameinputTypeUnidentified
                }
            }
        }
        catch let error as NSError {
            print(error)
        }
        
        // self.head = self.readHeader(verbose : true)
        
        // self.read_emi()
    }
    func getData() -> Data {
        return _file_hdl!.data!
    }
    private func __del__() {
        // close the file stream in destructor.
        do {
            try self._file_hdl?.close()
        }
        catch let error { print(error) }
    }
    
    private func enter() -> FileSer {
        // implement python's with statement (not sure what this does)
        return self
    }
    
    private func  __exit__(exception_type : String, exception_value : Int, traceback : NSError) {
        /*Implement python's with statement
        and close the file via __del__()
        */
        self.__del__()
        return
    }

    private func __str__() -> String {
        return "ncempy SER data set"
    }

    func readHeader(verbose : Bool = false) throws -> [String:Any]? {
        /*Read and return the SER files header.
        Parameters
        ----------
            verbose: bool
                True to get extensive output while reading the file.
        Returns
        -------
            : dict
                 The header of the SER file as dict.
        */
        // prepare empty dict to be populated while reading
        var head_dictionary : [String:Any]? = [:] // being replaced with struct.
        var head = SerHeader()
        // go back to beginning of file
        self._file_hdl?.resetOffsetToZero()
        if _file_hdl == nil {
            throw FileSERErrors.UninitializedFileRead
        }
            // read 3 int16
        do {
            guard let data : [Int16] = try self._file_hdl?.fromfileBI( count: 3 ) else { throw FileSERErrors.DataReadFail }
            // ByteOrder (only little Endian expected)
        // idea : Initialize whatever data was there before and then just set data to nil when done.
    
        if !(self._dictByteOrder.keys.contains(data[0])) {
            throw FileSERErrors.BetrayedLittleEndianExpectation
        }
        // head['ByteOrder'] = data[0]
        if verbose {
            print("ByteOrder:\(data[0] ),\(String(describing: self._dictByteOrder[data[0]]))")
        }
            
            // SeriesID, check whether TIA Series Data File
        if data[1] != 0x0197 {
            throw FileSERErrors.NotSERError                  // now a throw.
        }
        head.SeriesID = data[1]
        
        head.SeriesID = data[1]
    
        if verbose {
            print("SeriesID:\t \(data[0]) \tTIA Series Data File")
        }
        // SeriesVersion
        if !self._dictSeriesVersion.keys.contains(data[2] ) {
            fatalError( "Unknown TIA version: \(String(data[2]) )")
        }
        head.SeriesVersion = data[2]
        if verbose{
            print(String(format: "SeriesVersion:\t %@,\t \(String(describing: _dictSeriesVersion[ data[2] ]))", String(data[2]) ))
        }
                
        // MARK: version dependent file format for below ( important line is here for int64 )

        if head.SeriesVersion == 0x0210 {
            self.offset_dtype = "<i4"
        }
        else {
            // head.SeriesVersion==0x220:
            self.offset_dtype = "<i8"
        }

        // read 4 int32
        // Kind of inefficient way of writing code with guard let over and over, but it's better than before where I had to force each type.
        guard let data : [Int32] = try _file_hdl?.fromfileBI(count : 4) else { throw FileSERErrors.DataReadFail}

        // DataTypeID
        print(_file_hdl!.off)
        if !self._dictDataTypeID.keys.contains(data[0]) {
            throw FileSERErrors.DataTypeUndefined     }
        head.DataTypeID = data[0]
        if verbose {
            print( String(format: "DataTypeID:\t %@,\t %@", String(data[0]), self._dictDataTypeID[data[0]]!))
        }
    // TagTypeID
        if !self._dictTagTypeID.keys.contains(data[1]) {
            throw FileSERErrors.DataTypeUndefined
        }
        head.TagTypeID = data[1]
        if verbose {
            print(String(format: "DataTagID:\t %@,\t %@", String(data[1]), String(describing: self._dictTagTypeID[data[1]])))
        }
    // TotalNumberElements
        if !(data[2] >= 0){
            throw "Negative total number of elements: \(data[2])"
        }
        head.TotalNumberElements = data[2]
        if verbose {
            print("TotalNumberElements:\(data[2])")
        }
    // ValidNumberElements
        if !(data[3] >= 0){
            throw "Negative valid number of elements: \(String(data[3]))"
        }
        head.ValidNumberElements = data[3]
        MetaArray = [SerMeta].init(repeating : SerMeta(), count : Int(head.ValidNumberElements))
        self.metaArray = []
        if verbose{
            print("ValidNumberElements:\(String(data[3]))")
        }

        // OffsetArrayOffset, sensitive to SeriesVersion
     
        let errMsg = "Error in getting generic type to be \(offset_dtype) during reading. check switch statement"
        
        switch offset_dtype! {
        
        case "<i4":
            guard let data : [Int32] = try _file_hdl?.fromfileBI() else { throw FileSERErrors.DataReadFail }
            head.OffsetArrayOffset = Int(data[0])
        case "<i8":
            guard let data : [Int64] = try _file_hdl?.fromfileBI() else { throw FileSERErrors.DataReadFail}
            head.OffsetArrayOffset = Int(data[0])
        default :
            print("we got nowhere, the file data type string from  " + offset_dtype! + "wasn't present in the switch statement. for DataOffsetArray")

        }
        
        if verbose{
            print("DataOffsetArray:\(String(describing: data)) \t (as type \(type(of: data[0])))")
        }
      
        // NumberDimensions
        guard let data : [Int32] = try _file_hdl?.fromfileBI(count : 1) else { throw FileSERErrors.DataReadFail }
        if !(data[0] >= 0){
            fatalError("Negative number of dimensions")
        }
        head.NumberDimensions = data[0]
        if verbose {
            print("NumberDimensions:\(data[0])")
        }
        // Dimensions array
        var dimensions : [SerDimensionDescriptor] = [] // set type

        for i in 0..<head.NumberDimensions {
            var this_dim = SerDimensionDescriptor()
            if verbose{
                print("reading Dimension \(i)")
            }
        
            // DimensionSize
            guard let data : [Int32] = try _file_hdl?.fromfileBI() else { throw FileSERErrors.DataReadFail }
            this_dim.DimensionSize = data[0]
            if verbose{
                print("DimensionSize:\(data[0])")
            }
            
            guard let data : [Float64] = try _file_hdl?.fromfileBF(count: 2) else { throw FileSERErrors.DataReadFail }

            // CalibrationOffset
            this_dim.CalibrationOffset = data[0]
            if verbose{
                print("CalibrationOffset:\(data[0])")
            }
            // CalibrationDelta
            this_dim.CalibrationDelta = data[1]
            if verbose {
                print("CalibrationDelta:\(data[1])")
            }
            guard let data : [Int32] = try _file_hdl?.fromfileBI(count: 2) else { throw FileSERErrors.DataReadFail }

            // CalibrationElement
            this_dim.CalibrationElement = data[0]
            if verbose{
                print("CalibrationElement:\(data[0])")
            }
            // DescriptionLength
            var n = data[1]
            
            // Description
            guard let data : [Int8] = try _file_hdl?.fromfileBI(count : Int(littleEndian: Int(n)) ) else { throw FileSERErrors.DataReadFail } //dtype: "<i1"
           // data = ''.join(map(chr, data)) in python
            this_dim.Description = String( data.map { Character( UnicodeScalar( UInt8($0) ) ) }) //happy
            if verbose{
                print("Description:\(data)")
            }
            // UnitsLength
            guard let data : [Int32] = try _file_hdl?.fromfileBI( count : 1) else { throw FileSERErrors.DataReadFail }
            n = data[0]

            // Units
            guard let data : [Int8] = try _file_hdl?.fromfileBI( count : Int(littleEndian: Int(n) )) else { fatalError("Data read for Units failed in header reading.")}
            //data = ''.join(map(chr, data))  // What is this???
            this_dim.Units = data
            if verbose{
                print("Units:\(String(describing: data))")
            }
            dimensions.append(this_dim)
        }
        // save dimensions array as tuple of dicts in head dict.
        // MARK: Not sure how to copy this action in Swift ( tuple(dimensions) ) in python.
        head.Dimensions = dimensions

        // Offset array,  error if this was set incorrectly would likely have been thrown earlier.
       _file_hdl?.setOffset(  head.OffsetArrayOffset )
      
        let count = Int(head.ValidNumberElements)
        // DataOffsetArray and  TagOffsetArray are done in this switch.

        if verbose {
            print("reading in DataOffsetArray")
        }
        switch offset_dtype! {
        case "<i4":
            guard let data : [Int32]  = try _file_hdl?.fromfileBI(count : count) else { throw FileSERErrors.DataReadFail}

            head.DataOffsetArray  = data.map { Int($0) }
            
            guard let data : [Int32]  = try _file_hdl?.fromfileBI(count : count) else { throw FileSERErrors.DataReadFail}

            head.TagOffsetArray = data.map { Int($0) }// .tolist() in python
            if verbose {
                print("reading in TagOffsetArray")
            }
        case "<i8":
            guard let data : [Int64] = try _file_hdl?.fromfileBI(count : count) else { throw FileSERErrors.DataReadFail }

            head.DataOffsetArray  = data.map { Int($0) }
            
            guard let data : [Int64] = try _file_hdl?.fromfileBI(count : count) else { throw FileSERErrors.DataReadFail }
           
            head.TagOffsetArray = data.map { Int($0) }
            if verbose {
                print("reading in TagOffsetArray")
            }
        default :
            print("we got nowhere, the file data type string from  " + offset_dtype! + "wasn't present in the offset_dtype switch statement. of npDataTypetoSwiftArray")

        }
        }
        catch let error { throw error }
        self.head = head_dictionary
        self.Head = head
        return head_dictionary
    }
    func getHeaderDescription() -> SerHeaderDescription{
        guard let header = Head else { return SerHeaderDescription() }
        headerDescription.SeriesID = (header.SeriesID == 0x0197) ? "ES Vision Series Data File" : "nil"                              // Series id not found among descriptors (ES Vision Series Data File)
        headerDescription.SeriesVersion = _dictSeriesVersion[header.SeriesVersion] ?? "nil"
        headerDescription.DataTypeID    = _dictDataTypeID[header.DataTypeID] ?? "nil"
        headerDescription.TagTypeID     = _dictTagTypeID[header.TagTypeID] ?? "nil"
        headerDescription.TotalNumberElements = String(header.TotalNumberElements) // rows * columns
        headerDescription.ValidNumberElements = String(header.ValidNumberElements)
        headerDescription.NumberDimensions    = String(header.NumberDimensions)
        for description in header.Dimensions {
            var currDescription = SerDimensionDetailedDescription()
            currDescription.Description = description.Description
            currDescription.CalibrationDelta    = String(description.CalibrationDelta)
            currDescription.CalibrationOffset   = String(description.CalibrationOffset)
            currDescription.DimensionSize       = String(description.DimensionSize)
            currDescription.Units               = String(describing: description.Units )
            currDescription.CalibrationElement  = String(description.CalibrationElement)
            headerDescription.Dimensions.append(currDescription)
        }
        headerDescription.TagOffsetArray      = String(describing: header.TagOffsetArray)
        headerDescription.DataOffsetArray     = String(describing: header.DataOffsetArray)
        return headerDescription
    }
// Needs Swift specific error handling.
    func _checkIndex(i : Int?) throws {
        /* Check index i for sanity, otherwise raise Exception.
        Parameters
        ----------
            i: int
                Index.
        */

        // check type (is implicit in getDataset(index: Int) - swift is often specific while python isnt.)
        if i == nil {
            throw FileSERErrors.NonIntegerIndex
        }
        
        // check whether in range
        // for now this is neat, however maybe in future headache inducer (maybe I would need it to be optional), some refactoring annoyances like having to use guard statements again would occur.
        do {
            guard let UnwrappedHeadValidNumberElements = self.Head?.ValidNumberElements else { throw "Head.ValidNumberElements is nil"}
            if i! < 0 || i! >= Int( UnwrappedHeadValidNumberElements  ) {
                throw String(format: "Index out of range accessing element %@ of %@ valid elements", String(describing: i), String( describing: Head?.ValidNumberElements))
            }
        } catch let error as NSError { }
        return
    }
    // Only way that top level can infer what final type the dataset is, is to run the Meta.Dataset determining part of the function below first, so that the type given by the file can be switched in order to fix inferring the final type.
    
    func getMetaType( index : Int, verbose : Bool = false) throws -> SerMeta {
        // Check if fileRead() defined
        if self._file_hdl == nil {
            throw "_file_hdl not initialized in SerReader."
        }
        // check index, will raise Exceptions if not
        do {
            try self._checkIndex(i: index)
        }
        catch let error as NSError { throw error } // Throwing errors should be done in the _checkIndex() function

        // used to be a switch statement but no longer necessary with Int casting happening in init() for these values.
        
        if verbose {
            print("Setting offset for dataArrayOffset to \(String(describing: Head?.DataOffsetArray))")
        }
        self._file_hdl?.setOffset(Head!.DataOffsetArray[index])

        // read meta
        var meta : [String:Any] = [:]
        var Meta : SerMeta? = nil
        var n = 1
        // number of calibrations depends on DataTypeID

       if self.Head?.DataTypeID == 0x4120 {
            if verbose {
                print("dataTypeIDInt is \(self.Head?.DataTypeID ?? 0) == 0x4120, there is only 1 calibration.")
            }
            n = 1
        }
        else if self.Head?.DataTypeID == 0x4122 {
            if verbose {
                print("dataTypeIDInt is \(toascii( self.Head?.DataTypeID ?? 0) ) == 0x4122, there are 2 calibrations.")
            }
            n = 2
        }
        else {
            throw FileSERErrors.UninitializedHead
        }
        
        var cals : [Any] = []
        var Cals : [SerCalibrationDescriptor] = []
        do {
        // read in the calibrations
        Meta = SerMeta.init()

        for i in 0..<n {
            if verbose {
                print("Reading calibration \(i)")
            }
            var this_cal : [String: Any ] = [:]
            var This_cal : SerCalibrationDescriptor
            
            guard let data : [Float64] = try _file_hdl?.fromfileBF(count : 2) else { throw FileSERErrors.DataReadFail} // "<f8"
            // CalibrationOffset
            this_cal["CalibrationOffset"] = data[0]
            This_cal = SerCalibrationDescriptor.init()
            This_cal.CalibrationOffset = data[0]
            if verbose {
                print("CalibrationOffset:\t\(data[0])")
            }
            // CalibrationDelta
            this_cal["CalibrationDelta"] = data[1]
            This_cal.CalibrationDelta    = data[1]
            if verbose {
                print("CalibrationDelta:\t\(data[1])")
            }
            guard let data : [Int32] = try _file_hdl?.fromfileBI() else { throw FileSERErrors.DataReadFail } // "<i4"
            // CalibrationElement
            this_cal["CalibrationElement"] = data[0]
            This_cal.CalibrationElement = data[0]
            if verbose{
                print("CalibrationElement:\(data[0])")
            }
            cals.append(this_cal)
            Cals.append(This_cal)
        }
        }
        catch let error { throw error }
        meta["Calibration"] = cals // tuple(cals) in python
        if Meta == nil {
            throw "Meta never initialized"
        }
        Meta?.Calibration = Cals
        
        guard let data : [Int16] = try _file_hdl?.fromfileBI() else { throw FileSERErrors.DataReadFail } // "<i2"
        
        // DataType
        meta["DataType"] = Int(data[0])
        Meta!.DataType    = data[0]
        if !self._dictDataType.keys.contains(Meta!.DataType) {
            throw "Unknown DataType: \(data[0])"
        }
        if verbose {
            print( String(format: "DataType:\t%@,\t%@", String( describing :_dictDataType[data[0]]), String( describing:  _dictDataType[data[0]]) ) )
        }

        // new way of figuring out type.
        if _dictDataType[Meta!.DataType] == nil {
            throw FileSERErrors.DataTypeUndefined
        }
        let DataSetRawType = getGenericType( (_dictDataType[Meta!.DataType])! ) // this Generic stuff may not even be necessary anymore since I switch on each individual type at the top level anyways.
        Meta?.SerBinaryType = DataSetRawType
        return Meta!
    }

    func getDataset<GenericIntType : BinaryInteger, GenericFloatType : BinaryFloatingPoint>(index : Int, verbose : Bool = false) throws -> ([GenericIntType]?, [GenericFloatType]?, SerMeta) { // I decided to have to dataset outputs.. This switch on which turns out to be nil will occur in the very beginning of the function, this important info should be made a Header item.
        
        /* Retrieve data and meta data for one image or spectra
        from the file.
        Parameters
        ----------
            index: int
                Index of dataset.
            verbose: bool, optional
                True to get extensive output while reading the file.
        Returns
        -------
            dataset: tuple, 2 elements in form (data metadata)
                Tuple contains data as np.ndarray and metadata
                (pixel size, etc.) as a dict.
        */
        // Check if fileRead() defined
        if self._file_hdl == nil {
            throw "_file_hdl not initialized in SerReader."
        }
        // check index, will raise Exceptions if not
        do {
            try self._checkIndex(i: index)
        }
        catch let error as NSError { throw error } // Throwing errors should be done in the _checkIndex() function

        // used to be a switch statement but no longer necessary with Int casting happening in init() for these values.
        
        if verbose {
            print("Setting offset for dataArrayOffset to \(Head?.DataOffsetArray)")
        }
        self._file_hdl?.setOffset(Head!.DataOffsetArray[index])

        // read meta
        var meta : [String:Any] = [:]
        var Meta : SerMeta? = nil
        var n = 1
        // number of calibrations depends on DataTypeID

       if self.Head?.DataTypeID == 0x4120 {
            if verbose {
                print("dataTypeIDInt is \(self.Head?.DataTypeID ?? 0) == 0x4120, there is only 1 calibration.")
            }
            n = 1
        }
        else if self.Head?.DataTypeID == 0x4122 {
            if verbose {
                print("dataTypeIDInt is \(toascii( self.Head?.DataTypeID ?? 0) ) == 0x4122, there are 2 calibrations.")
            }
            n = 2
        }
        else {
            throw FileSERErrors.UninitializedHead
        }
        
        var cals : [Any] = []
        var Cals : [SerCalibrationDescriptor] = []
        do {
        // read in the calibrations
        Meta = SerMeta.init()

        for i in 0..<n {
            if verbose {
                print("Reading calibration \(i)")
            }
            var this_cal : [String: Any ] = [:]
            var This_cal : SerCalibrationDescriptor
            
            guard let data : [Float64] = try _file_hdl?.fromfileBF(count : 2) else { throw FileSERErrors.DataReadFail} // "<f8"
            // CalibrationOffset
            this_cal["CalibrationOffset"] = data[0]
            This_cal = SerCalibrationDescriptor.init()
            This_cal.CalibrationOffset = data[0]
            if verbose {
                print("CalibrationOffset:\t\(data[0])")
            }
            // CalibrationDelta
            this_cal["CalibrationDelta"] = data[1]
            This_cal.CalibrationDelta    = data[1]
            if verbose {
                print("CalibrationDelta:\t\(data[1])")
            }
            guard let data : [Int32] = try _file_hdl?.fromfileBI() else { throw FileSERErrors.DataReadFail } // "<i4"
            // CalibrationElement
            this_cal["CalibrationElement"] = data[0]
            This_cal.CalibrationElement = data[0]
            if verbose{
                print("CalibrationElement:\(data[0])")
            }
            cals.append(this_cal)
            Cals.append(This_cal)
        }
        }
        catch let error { throw error }
        meta["Calibration"] = cals // tuple(cals) in python
        if Meta == nil {
            throw "Meta never initialized"
        }
        Meta?.Calibration = Cals
        
        guard let data : [Int16] = try _file_hdl?.fromfileBI() else { throw FileSERErrors.DataReadFail } // "<i2"
        
        // DataType
        meta["DataType"] = Int(data[0])
        Meta!.DataType    = data[0]
        if !self._dictDataType.keys.contains(Meta!.DataType) {
            throw "Unknown DataType: \(data[0])"
        }
        if verbose {
            print( String(format: "DataType:\t%@,\t%@", String( describing :_dictDataType[data[0]]), String( describing:  _dictDataType[data[0]]) ) )
        }
        
        // In Swift it is important to specify type, so I'll do this with a switch. (On meta)
        var dataset_integer  : [GenericIntType]? = nil  // in case something goes wrong (serves as initialization of this variable in swift)
        var dataset_floating : [GenericFloatType]? = nil
        
        
        guard let dataTypeString = meta["DataType"] as? Int else {fatalError("meta[\"DataType\"] couldn't be read as Int.")}

        guard let fileDType = _dictDataType[Int16(dataTypeString)] else { fatalError("_dictDataType[meta[\"DataType\"]] couldn't be converted to string.")}
        guard let fileDTypeStr = fileDType as? String else { fatalError("couldn't parse file _dictDataType[Meta[\"DataType\"]] to string.")}
       
        // new way of figuring out type.
        if _dictDataType[Meta!.DataType] == nil {
            throw FileSERErrors.DataTypeUndefined
        }
        let DataSetRawType = getGenericType( (_dictDataType[Meta!.DataType])! ) // this Generic stuff may not even be necessary anymore since I switch on each individual type at the top level anyways.
        Meta?.SerBinaryType = DataSetRawType
        if Head!.DataTypeID == 0x4120 {
            // 1D data element
        print("1D data element")
           
            if verbose{
                print("ArrayShape:\t\(data)")
            }
            guard let count : Int = (meta["ArrayShape"] as! [Int]?)?[0] else { throw "Retrieval of stored meta[\"ArrayShape\"] couldn't be typecast to int."  }
        // workaround : test what meta["DataType"] is, then switch on the datatype such that swift knows what type dataset will be.
            // must be int because this was the function called. The other will be determined with a switch higher up.
            switch Meta?.SerBinaryType {
            case .BinaryInteger:
                dataset_integer = try _file_hdl?.npDataTypetoSwiftArrayBI(dtype: fileDTypeStr, count: count)
            case .BinaryFloatingPoint:
                dataset_floating = try _file_hdl?.npDataTypetoSwiftArrayBF(dtype : fileDTypeStr, count: count)
            default :
                dataset_integer = nil
                dataset_floating = nil
            }
            
        } else if Head!.DataTypeID == 0x4122 {

            // 2D data element
            print("2D data element")
            guard let data : [Int32] = try _file_hdl?.fromfileBI(count : 2) else { fatalError("Read of ArrayShape of 2D element failed.") } // "<i4"
            
            var castData : [Int] = [Int].init(repeating: 0, count: 2);
            var i = 0
            data.forEach { elem in castData[i] = (Int(elem)); i += 1; } // again this is effectively what data.tolist() is doing in python. I will use map in a moment.
            // ArrayShape
            
            meta["ArrayShape"] = castData
            Meta?.ArrayShape = data.map { Int($0) }
        
            if verbose{
                print("ArrayShape:\t\(data)")
            }
        
            guard var arrayShape = meta["ArrayShape"] as? [Int] else {  fatalError("error parsing header attribute \"arrayShape\" as Int") }
            arrayShape = Meta!.ArrayShape
            // dataset
            let arrShapeX = arrayShape[0]
            let arrShapeY = arrayShape[1]
            let count = arrShapeX * arrShapeY
            switch Meta?.SerBinaryType {
            case .BinaryInteger:
                dataset_integer = try _file_hdl?.npDataTypetoSwiftArrayBI(dtype: fileDTypeStr, count: count)
            case .BinaryFloatingPoint:
                dataset_floating = try _file_hdl?.npDataTypetoSwiftArrayBF(dtype : fileDTypeStr, count: count)
            default :
                dataset_integer = nil
                dataset_floating = nil
            }
           // try _file_hdl!.close() // may free up memory, I need this though for file exporting.
        }
        else { throw FileSERErrors.DataTypeIDUndefined }
        dataset_integer?.reverse()
        dataset_floating?.reverse()// for little endian
        if Meta == nil {
            throw "Meta not initialized"
        }
        self.MetaArray[index] = Meta!
        
        return (dataset_integer, dataset_floating, Meta!) // both kinds make it out of this function, it is further task to differentiate at runtime. (This info is available form Meta.SerBinaryType
    }
        

    func _getTag( index : Int, verbose : Bool = false) throws -> [String:Any] {
        /*Retrieve tag from data file.
        Parameters
        ----------
            index: int
                Index of tag.
            verbose: bool
                True to get extensive output while reading the file.
        Returns
        -------
            tag: dict
                Tag as a python dictionary.
        */

        // check index, will raise Exceptions if not
        do {
            try self._checkIndex(i: index)
        }
        catch {  } // Throwing errors would be done in the _checkIndex() function..

        if verbose{
            print( String(format: "Getting tag %@ of %@.",index, self.head!["ValidNumberElements"] as! CVarArg) )
        }
        
        var tag : [String:Any] = [:]
        
        
            // bad tagoffsets occurred pointing to the end of the file

            // go to dataset in file
        
        if Head == nil {
            throw FileSERErrors.UninitializedHead
        }
        if _file_hdl == nil {
            throw FileSERErrors.UninitializedFileRead
        }
        self._file_hdl?.setOffset( Head!.TagOffsetArray[index] ) // 0 in second argument.

        guard let data : [Int32] = try _file_hdl?.fromfileBI(count:2) else { throw FileSERErrors.DataReadFail } // "<i4"

            // TagTypeID
        tag["TagTypeID"] = data[0]
// MARK: Friday notes : use a struct and see which data is to be used.
        
        // output was OptionalValue(72)
                
        guard let tagTypeIDHead = self.head!["TagTypeID"],
              let tagTypeIDTag = tag["TagTypeID"] as? Int
        else { fatalError("TagTypeID was not read correctly as Int")}
            // only proceed if TagTypeID is the same like in the file header (bad TagOffsetArray issue)
        if self.head!["TagTypeID"] as! Int == tagTypeIDTag {
            if verbose{
                if let dataTagTypeIdData0 = self._dictTagTypeID[ data[0] ] {
                print(String(format: "TagTypeID:\t\"%@\",\t\"%@\"", data[0] , dataTagTypeIdData0 )) // {://06x} is used in python for further formatting settings
                    }
            }
                // Time
                tag["Time"] = data[1]
            if verbose{
                    print("Time:\t \(data[1])")
            }
                // check for position
            if (tag["TagTypeID"] as! Int) == 0x4142{
                let data : [Float64] = try _file_hdl!.fromfileBF( count : 2) // "<f8"
                    // looks like all those guard lets weren't necessary ... oops
                    // PositionX
                    tag["PositionX"] = data[0]
                if verbose{
                        print("PositionX:\t\(data[0])")
                }
                    // PositionY
                    tag["PositionY"] = data[1]
                if verbose {
                        print("PositionY:\t{}\(data[1])")
                }
                }
            }
        
            else {
                // otherwise raise to get to default tag (before this was else: raise; raise tag["TagTypeID"] = 0...
            tag["TagTypeID"] = 0
            tag["Time"] = 0
            tag["PositionX"] = nil    // Nil a good substitute? ( np.nan before)
            tag["PositionY"] = nil }
        
        return tag
    }
    // float32 no matter what since model input only takes in Float32
    func GetHighDefCGImageFromSer(index: Int = 0) throws -> CGImage {
        var float32Arr : [Float32] = []
        if self.Head == nil {
            throw FileSERErrors.UninitializedHead
        }
  
        let FirstMeta : SerMeta = try self.getMetaType(index: 0)
        let np_Type = FirstMeta.DataType
        do {
            switch np_Type {
            case 1:
                // second tuple element will be null in all int cases and flipped for floats.
                let dataset : ([UInt8]?, [Float16]?, SerMeta) = try self.getDataset(index: 0,verbose: true)
                guard let uint8DSet = dataset.0 else { throw FileSERErrors.DataReadFail }
                float32Arr = try formatArrDataForMLModel(dataSet: uint8DSet)
            case 2:
                let dataset : ([UInt16]?, [Float16]?, SerMeta) = try self.getDataset(index: 0,verbose: true)
                guard let uint16DSet = dataset.0 else { throw FileSERErrors.DataReadFail }
                float32Arr = try formatArrDataForMLModel(dataSet: uint16DSet )
            case 3:
                let dataset : ([UInt32]?, [Float16]?, SerMeta) = try self.getDataset(index: 0,verbose: true)
                guard let uint32DSet = dataset.0 else { throw FileSERErrors.DataReadFail }
                float32Arr = try formatArrDataForMLModel(dataSet: uint32DSet )
            case 4:
                let dataset : ([Int8]?, [Float16]?, SerMeta) = try self.getDataset(index: 0,verbose: true)
                guard let int8DSet = dataset.0 else { throw FileSERErrors.DataReadFail }
                float32Arr = try formatArrDataForMLModel(dataSet: int8DSet )
            case 5:
                let dataset : ([Int16]?, [Float16]?, SerMeta) = try self.getDataset(index: 0,verbose: true)
                guard let int16DSet = dataset.0 else { throw FileSERErrors.DataReadFail }
                float32Arr = try formatArrDataForMLModel(dataSet: int16DSet )
            case 6:
                let dataset : ([Int32]?, [Float16]?, SerMeta) = try self.getDataset(index: 0,verbose: true)
                guard let int32DSet = dataset.0 else { throw FileSERErrors.DataReadFail }
                float32Arr = try formatArrDataForMLModel(dataSet: int32DSet )
            case 7:
                let dataset : ([UInt8]?, [Float32]?, SerMeta) = try self.getDataset(index: 0,verbose: true)
                guard let float32DSet = dataset.1 else { throw FileSERErrors.DataReadFail }
                float32Arr = try formatArrDataForMLModel(dataSet: float32DSet )
            case 8:
                let dataset : ([UInt8]?, [Float64]?, SerMeta) = try self.getDataset(index: 0,verbose: true)
                guard let float64Dset = dataset.1 else { throw FileSERErrors.DataReadFail }
                print("we may loose fidelity after processing, bit depth input is twice model input (32 bit vs 64 bit).")
                float32Arr = try formatArrDataForMLModel(dataSet: float64Dset )
            case 9:
                throw FileSERErrors.ComplexNotProgrammedYet
            case 10:
                throw FileSERErrors.ComplexNotProgrammedYet
            default :
                throw FileSERErrors.DataTypeUndefined
            }
            // meta entries will be structs in the future.
            let arrShape : [Int] = self.MetaArray[0].ArrayShape
            let width = arrShape[0]
            let height :  Int? = arrShape[1]
                if height == nil {
                    throw FileSERErrors.Expected2DArrayGot1DArray
                }
            let count = width * height!
                if count == 0 {
                    throw FileSERErrors.ZeroSizedDimension
                }
            let dataPointer = UnsafeMutableRawPointer.allocate(byteCount: 4*count, alignment: 0)
            dataPointer.copyMemory(from: &float32Arr, byteCount: 4*count)
            let bitsPerComponent = 32
            let bytesPerPixel = 4

            let bitsPerPixel = 8 * bytesPerPixel
            let bytesPerRow: Int = width * bytesPerPixel;
                
            let flatCFData = CFDataCreate(nil, dataPointer.assumingMemoryBound(to: UInt8.self), count * bytesPerPixel )
            let cgDataProvider = CGDataProvider.init(data: flatCFData! )
            let deviceColorSpace = CGColorSpaceCreateDeviceGray()
            defer {
         dataPointer.deallocate()
            }
            guard let serImage = CGImage.init(width: width, height: height!,
                                        bitsPerComponent: bitsPerComponent,
                                        bitsPerPixel: bitsPerPixel,
                                        bytesPerRow: bytesPerRow,
                                        space: deviceColorSpace,
                                        bitmapInfo: [.byteOrder32Little, .floatComponents],
                                        provider: cgDataProvider!,
                                        decode: nil,           // No remapping
                                        shouldInterpolate: true,
                                        intent: .defaultIntent)
            else { throw FileSERErrors.CGConversionError}
            //https://stackoverflow.com/questions/51372245/swift-convert-byte-array-into-ciimage
                
            return serImage
        } catch let error as NSError { throw error }
        
    }
}
