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
    
    init(fileName : Any?, verbose : Bool = false, mobileBundle : Bool = true ) {

        // necessary declarations, if something fails
        self._file_hdl = nil
            //  self.emi = nil
        self.head = nil

        self.offset_dtype = nil
        
        self.metaArray = nil
       
        // try opening the file
        do {
            if mobileBundle {  // if we want to grab from asset catalogue.
                if let asset = NSDataAsset(name: fileName! as! String) {
                    self._file_hdl = fRead(data: asset.data)
                }
                else {
                    fatalError("Ser file not found in main bundle or NSDataAsset not initialized:: \(filename)")
                }
            } else {
                // we initialize the data in a different way (see convenience init below.)
            }
        }
        // self.head = self.readHeader(verbose : true)
        // self.read_emi()
    }
    
    convenience init(serObject: SerEntity) {
        self.init(fileName: serObject.name, mobileBundle: false)
        _file_hdl = fRead(data: serObject.serBinary)
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
                float32Arr = try ArrayFormatter.arrayForMLModel(dataSet: uint8DSet)
            case 2:
                let dataset : ([UInt16]?, [Float16]?, SerMeta) = try self.getDataset(index: 0,verbose: true)
                guard let uint16DSet = dataset.0 else { throw FileSERErrors.DataReadFail }
                float32Arr = try ArrayFormatter.arrayForMLModel(dataSet: uint16DSet )
            case 3:
                let dataset : ([UInt32]?, [Float16]?, SerMeta) = try self.getDataset(index: 0,verbose: true)
                guard let uint32DSet = dataset.0 else { throw FileSERErrors.DataReadFail }
                float32Arr = try ArrayFormatter.arrayForMLModel(dataSet: uint32DSet )
            case 4:
                let dataset : ([Int8]?, [Float16]?, SerMeta) = try self.getDataset(index: 0,verbose: true)
                guard let int8DSet = dataset.0 else { throw FileSERErrors.DataReadFail }
                float32Arr = try ArrayFormatter.arrayForMLModel(dataSet: int8DSet )
            case 5:
                let dataset : ([Int16]?, [Float16]?, SerMeta) = try self.getDataset(index: 0,verbose: true)
                guard let int16DSet = dataset.0 else { throw FileSERErrors.DataReadFail }
                float32Arr = try ArrayFormatter.arrayForMLModel(dataSet: int16DSet )
            case 6:
                let dataset : ([Int32]?, [Float16]?, SerMeta) = try self.getDataset(index: 0,verbose: true)
                guard let int32DSet = dataset.0 else { throw FileSERErrors.DataReadFail }
                float32Arr = try ArrayFormatter.arrayForMLModel(dataSet: int32DSet )
            case 7:
                let dataset : ([UInt8]?, [Float32]?, SerMeta) = try self.getDataset(index: 0,verbose: true)
                guard let float32DSet = dataset.1 else { throw FileSERErrors.DataReadFail }
                float32Arr = try ArrayFormatter.arrayForMLModel(dataSet: float32DSet )
            case 8:
                let dataset : ([UInt8]?, [Float64]?, SerMeta) = try self.getDataset(index: 0,verbose: true)
                guard let float64Dset = dataset.1 else { throw FileSERErrors.DataReadFail }
                print("we may loose fidelity after processing, bit depth input is twice model input (32 bit vs 64 bit).")
                float32Arr = try ArrayFormatter.arrayForMLModel(dataSet: float64Dset )
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

// more needs to be researched about EMI/ EMD Resource: https://openncem.readthedocs.io/en/latest/ncempy.io.html
 /*   func writeEMD(filename) {
        /* Write SER data to an EMD file.
        Parameters
        ----------
            filename: str
                Name of the EMD file.
        */
        // Todo: Update this to be much simpler. Can write this in a couple of lines now using the fileEMD class
        // from ncempy.io import emd

        // create the EMD file and set version attributes
        do {
            f = try emd.fileEMD(filename)
        }
            catch {
            fatalError('Cannot write to file "{}"!'.format(filename))
            }
        // create EMD group
        grp = f.file_hdl['data'].create_group(os.path.basename(self._file_hdl.name))
        grp.attrs['emd_group_type'] = 1

        // use first dataset to layout memory
        data, first_meta = self.getDataset(0)
        first_tag = self._getTag(0)

        if self.head['DataTypeID'] == 0x4122:
            // 2D datasets
            self.head['ExperimentType'] = 'image'  // text indicator of the experiment type
            if first_tag['TagTypeID'] == 0x4142:
                // 2D mapping
                dset = grp.create_dataset('data', (self.head['Dimensions'][1]['DimensionSize'],
                                                   self.head['Dimensions'][0]['DimensionSize'],
                                                   first_meta['ArrayShape'][1], first_meta['ArrayShape'][0]),
                                          dtype=self._dictDataType[first_meta['DataType']])

                // collect time
                time = np.zeros((self.head['Dimensions'][0]['DimensionSize'],
                                 self.head['Dimensions'][1]['DimensionSize']), dtype='i4')

                // create mapping dims for checking
                map_xdim = self._createDim(self.head['Dimensions'][0]['DimensionSize'],
                                           self.head['Dimensions'][0]['CalibrationOffset'],
                                           self.head['Dimensions'][0]['CalibrationDelta'],
                                           self.head['Dimensions'][0]['CalibrationElement'])
                map_ydim = self._createDim(self.head['Dimensions'][1]['DimensionSize'],
                                           self.head['Dimensions'][1]['CalibrationOffset'],
                                           self.head['Dimensions'][1]['CalibrationDelta'],
                                           self.head['Dimensions'][1]['CalibrationElement'])
                // weird direction depend half pixel shifting
                map_xdim += 0.5 * self.head['Dimensions'][0]['CalibrationDelta']
                map_ydim -= 0.5 * self.head['Dimensions'][1]['CalibrationDelta']

                for y in range(self.head['Dimensions'][0]['DimensionSize']):
                    for x in range(self.head['Dimensions'][1]['DimensionSize']):
                        index = int(x + y * self.head['Dimensions'][0]['DimensionSize'])
                        print('converting dataset {} of {}, items ({}, {})'.format(index + 1,
                                                                                   self.head['ValidNumberElements'],
                                                                                   x, y))

                        // retrieve dataset and put into buffer
                        data, meta = self.getDataset(index)
                        dset[y, x, :, :] = data[:, :]

                        // get tag data per image
                        tag = self._getTag(index)
                        time[y, x] = tag['Time']

                        assert (np.abs(tag['PositionX'] - map_xdim[x]) < np.abs(tag['PositionX'] * 1e-8))
                        assert (np.abs(tag['PositionY'] - map_ydim[y]) < np.abs(tag['PositionY'] * 1e-8))

                        del data, meta, tag

                // create dimension datasets
                dims = []
                dims_time = []

                // Position Y
                assert self.head['Dimensions'][1]['Description'] == 'Position'
                dims.append((map_ydim, self.head['Dimensions'][1]['Description'],
                             '[{}]'.format(self.head['Dimensions'][1]['Units'])))
                dims_time.append((map_ydim, self.head['Dimensions'][1]['Description'],
                                  '[{}]'.format(self.head['Dimensions'][1]['Units'])))

                // Position X
                assert self.head['Dimensions'][0]['Description'] == 'Position'
                dims.append((map_xdim, self.head['Dimensions'][0]['Description'],
                             '[{}]'.format(self.head['Dimensions'][0]['Units'])))
                dims_time.append((map_xdim, self.head['Dimensions'][0]['Description'],
                                  '[{}]'.format(self.head['Dimensions'][0]['Units'])))

                dim = self._createDim(first_meta['ArrayShape'][1], first_meta['Calibration'][1]['CalibrationOffset'],
                                      first_meta['Calibration'][1]['CalibrationDelta'],
                                      first_meta['Calibration'][1]['CalibrationElement'])
                dims.append((dim, 'y', '[m]'))

                dim = self._createDim(first_meta['ArrayShape'][0], first_meta['Calibration'][0]['CalibrationOffset'],
                                      first_meta['Calibration'][0]['CalibrationDelta'],
                                      first_meta['Calibration'][0]['CalibrationElement'])
                dims.append((dim, 'x', '[m]'))

                // write dimensions
                for ii in range(len(dims)):
                    f.write_dim('dim{:d}'.format(ii + 1), dims[ii], grp)

                // write out time as additional dataset
                _ = f.put_emdgroup('timestamp', time, dims_time, parent=grp)
            else:
                // 1 entry series to single image
                if self.head['ValidNumberElements'] == 1:
                    // get image
                    data, meta = self.getDataset(0)
                    tag = self._getTag(0)

                    // create dimensions
                    dims = []

                    dim = self._createDim(first_meta['ArrayShape'][1],
                                          first_meta['Calibration'][1]['CalibrationOffset'],
                                          first_meta['Calibration'][1]['CalibrationDelta'],
                                          first_meta['Calibration'][1]['CalibrationElement'])
                    dims.append((dim, 'y', '[m]'))

                    dim = self._createDim(first_meta['ArrayShape'][0],
                                          first_meta['Calibration'][0]['CalibrationOffset'],
                                          first_meta['Calibration'][0]['CalibrationDelta'],
                                          first_meta['Calibration'][0]['CalibrationElement'])
                    dims.append((dim, 'x', '[m]'))

                    dset = grp.create_dataset('data', (first_meta['ArrayShape'][1],
                                                       first_meta['ArrayShape'][0]),
                                              dtype=self._dictDataType[first_meta['DataType']])

                    dset[:, :] = data[:, :]

                    for i in range(len(dims)):
                        f.write_dim('dim{:d}'.format(i + 1), dims[i], grp)

                    dset.attrs['timestamp'] = tag['Time']
                else:
                    // simple series
                    dset = grp.create_dataset('data', (self.head['ValidNumberElements'],
                                                       first_meta['ArrayShape'][1], first_meta['ArrayShape'][0]),
                                              dtype=self._dictDataType[first_meta['DataType']])

                    // collect time
                    time = np.zeros(self.head['ValidNumberElements'], dtype='i4')

                    for i in range(self.head['ValidNumberElements']):
                        print('converting dataset {} of {}'.format(i + 1, self.head['ValidNumberElements']))

                        // retrieve dataset and put into buffer
                        data, meta = self.getDataset(i)
                        dset[i, :, :] = data[:, :]

                        // get tag data per image
                        tag = self._getTag(i)
                        time[i] = tag['Time']

                    // create dimension data sets
                    dims = []

                    // first SER dimension is number
                    assert self.head['Dimensions'][0]['Description'] == 'Number'

                    dim = self._createDim(self.head['Dimensions'][0]['DimensionSize'],
                                          self.head['Dimensions'][0]['CalibrationOffset'],
                                          self.head['Dimensions'][0]['CalibrationDelta'],
                                          self.head['Dimensions'][0]['CalibrationElement'])
                    dims.append((dim[0:self.head['ValidNumberElements']],
                                 self.head['Dimensions'][0]['Description'],
                                 '[{}]'.format(self.head['Dimensions'][0]['Units'])))

                    dim = self._createDim(first_meta['ArrayShape'][1],
                                          first_meta['Calibration'][1]['CalibrationOffset'],
                                          first_meta['Calibration'][1]['CalibrationDelta'],
                                          first_meta['Calibration'][1]['CalibrationElement'])
                    dims.append((dim, 'y', '[m]'))

                    dim = self._createDim(first_meta['ArrayShape'][0],
                                          first_meta['Calibration'][0]['CalibrationOffset'],
                                          first_meta['Calibration'][0]['CalibrationDelta'],
                                          first_meta['Calibration'][0]['CalibrationElement'])
                    dims.append((dim, 'x', '[m]'))

                    // write dimensions
                    for i in range(len(dims)):
                        f.write_dim('dim{:d}'.format(i + 1), dims[i], grp)

                    // write out time as additional dim vector
                    f.write_dim('dim1_time', (time, 'timestamp', '[s]'), grp)

        elif self.head['DataTypeID'] == 0x4120:
            // 1D datasets; spectra
            self.head['ExperimentType'] = 'spectrum'  // text indicator of the experiment type

            if first_tag['TagTypeID'] == 0x4142:
                // 2D mapping
                dset = grp.create_dataset('data', (self.head['Dimensions'][1]['DimensionSize'],
                                                   self.head['Dimensions'][0]['DimensionSize'],
                                                   first_meta['ArrayShape'][0]),
                                          dtype=self._dictDataType[first_meta['DataType']])

                time = np.zeros((self.head['Dimensions'][0]['DimensionSize'],
                                 self.head['Dimensions'][1]['DimensionSize']), dtype='i4')

                // create mapping dims for checking
                map_xdim = self._createDim(self.head['Dimensions'][0]['DimensionSize'],
                                           self.head['Dimensions'][0]['CalibrationOffset'],
                                           self.head['Dimensions'][0]['CalibrationDelta'],
                                           self.head['Dimensions'][0]['CalibrationElement'])
                map_ydim = self._createDim(self.head['Dimensions'][1]['DimensionSize'],
                                           self.head['Dimensions'][1]['CalibrationOffset'],
                                           self.head['Dimensions'][1]['CalibrationDelta'],
                                           self.head['Dimensions'][1]['CalibrationElement'])
                // weird direction depend half pixel shifting
                map_xdim += 0.5 * self.head['Dimensions'][0]['CalibrationDelta']
                map_ydim -= 0.5 * self.head['Dimensions'][1]['CalibrationDelta']

                for y in range(self.head['Dimensions'][0]['DimensionSize']):
                    for x in range(self.head['Dimensions'][1]['DimensionSize']):
                        index = int(x + y * self.head['Dimensions'][0]['DimensionSize'])
                        print('converting dataset {} of {}, items ({}, {})'.format(index + 1,
                                                                                   self.head['ValidNumberElements'],
                                                                                   x, y))

                        // retrieve dataset and put into buffer
                        data, meta = self.getDataset(index)
                        dset[y, x, :] = np.copy(data[:])

                        // get tag data per image
                        tag = self._getTag(index)
                        time[y, x] = tag['Time']

                        assert (np.abs(tag['PositionX'] - map_xdim[x]) < np.abs(tag['PositionX'] * 1e-8))
                        assert (np.abs(tag['PositionY'] - map_ydim[y]) < np.abs(tag['PositionY'] * 1e-8))

                        del data, meta, tag

                // create dimension datasets
                dims = []
                dims_time = []

                // Position Y
                assert self.head['Dimensions'][1]['Description'] == 'Position'
                dims.append((map_ydim, self.head['Dimensions'][1]['Description'],
                             '[{}]'.format(self.head['Dimensions'][1]['Units'])))
                dims_time.append((map_ydim, self.head['Dimensions'][1]['Description'],
                                  '[{}]'.format(self.head['Dimensions'][1]['Units'])))

                // Position X
                assert self.head['Dimensions'][0]['Description'] == 'Position'
                dims.append((map_xdim, self.head['Dimensions'][0]['Description'],
                             '[{}]'.format(self.head['Dimensions'][0]['Units'])))
                dims_time.append((map_xdim, self.head['Dimensions'][0]['Description'],
                                  '[{}]'.format(self.head['Dimensions'][0]['Units'])))

                dim = self._createDim(first_meta['ArrayShape'][0], first_meta['Calibration'][0]['CalibrationOffset'],
                                      first_meta['Calibration'][0]['CalibrationDelta'],
                                      first_meta['Calibration'][0]['CalibrationElement'])
                dims.append((dim, 'E', '[m_eV]'))

                // write dimensions
                for i in range(len(dims)):
                    f.write_dim('dim{:d}'.format(i + 1), dims[i], grp)

                // write out time as additional dataset
                _ = f.put_emdgroup('timestamp', time, dims_time, parent=grp)

            else:
                // simple series
                dset = grp.create_dataset('data', (self.head['ValidNumberElements'], first_meta['ArrayShape'][0]),
                                          dtype=self._dictDataType[first_meta['DataType']])

                // collect time
                time = np.zeros(self.head['ValidNumberElements'], dtype='i4')

                for i in range(self.head['ValidNumberElements']):
                    print('converting dataset {} of {}'.format(i + 1, self.head['ValidNumberElements']))

                    // retrieve dataset and put into buffer
                    data, meta = self.getDataset(i)
                    dset[i, :] = data[:]

                    // get tag data per image
                    tag = self._getTag(i)
                    time[i] = tag['Time']

                // create dimension datasets
                dims = []

                // first SER dimension is number
                assert self.head['Dimensions'][0]['Description'] == 'Number'
                dim = self._createDim(self.head['Dimensions'][0]['DimensionSize'],
                                      self.head['Dimensions'][0]['CalibrationOffset'],
                                      self.head['Dimensions'][0]['CalibrationDelta'],
                                      self.head['Dimensions'][0]['CalibrationElement'])
                dims.append((dim[0:self.head['ValidNumberElements']], self.head['Dimensions'][0]['Description'],
                             '[{}]'.format(self.head['Dimensions'][0]['Units'])))

                dim = self._createDim(first_meta['ArrayShape'][0], first_meta['Calibration'][0]['CalibrationOffset'],
                                      first_meta['Calibration'][0]['CalibrationDelta'],
                                      first_meta['Calibration'][0]['CalibrationElement'])
                dims.append((dim, 'E', '[m_eV]'))

                // write dimensions
                for i in range(len(dims)):
                    f.write_dim('dim{:d}'.format(i + 1), dims[i], grp)

                // write out time as additional dim vector
                f.write_dim('dim1_time', (time, 'timestamp', '[s]'), grp)
        else:
            raise RuntimeError('Unknown DataTypeID')

            // put meta information from _emi to Microscope group, if available
        if self._emi:
            for key in self._emi:
                if not self._emi[key] is None:
                    f.microscope.attrs[key] = self._emi[key]

        // write comment into Comment group
        f.put_comment('Converted SER file "{}" to EMD using the openNCEM tools.'.format(self._file_hdl.name))
    }
*/
}
    /*
func read_emi(data: Data?) {
    /*Read the meta data from an emi file.
    Parameters                          Swift Parameters
    ----------
        filename: str or pathlib.Path       only raw Data.
            Path to the emi file.
    Returns
    -------
        : dict
            Dictionary of experimental metadata stored in the EMI file.
    */

    self._file_hdl = fRead(data: data)

    // dict to store _emi stuff
    var _emi: [Any:Any] = [:]

    // need anything readable from <ObjectInfo> to </ObjectInfo>
    // collect = False
    // data = b''
    // for line in f_emi:
    //    if b'<ObjectInfo>' in line:
    //        collect = True
    //    if collect:
    //        data += line.strip()
    //    if b'</ObjectInfo>' in line:
    //        collect = False

    // close the file
    // f_emi.close()

    metaStart = emi_data.find(b'<ObjectInfo>')
    metaEnd = emi_data.find(b'</ObjectInfo>')  // need to add len('</ObjectInfo>') = 13 to encompass this final tag

    root = ET.fromstring(emi_data[metaStart:metaEnd + 13])

    // strip of binary stuff still around
    // data = data.decode('ascii', errors='ignore')
    // matchObj = re.search('<ObjectInfo>(.+?)</ObjectInfo', data)
    // try:
    //    data = matchObj.group(1)
    // except:
    //    raise RuntimeError('Could not find _emi metadata in specified file.')

    // parse metadata as xml
    // root = ET.fromstring('<_emi>' + data + '</_emi>')

    // single items
    _emi['Uuid'] = root.findtext('Uuid')
    _emi['AcquireDate'] = root.findtext('AcquireDate')
    _emi['Manufacturer'] = root.findtext('Manufacturer')
    _emi['DetectorPixelHeight'] = root.findtext('DetectorPixelHeight')
    _emi['DetectorPixelWidth'] = root.findtext('DetectorPixelWidth')

    // Microscope Conditions
    grp = root.find('ExperimentalConditions/MicroscopeConditions')

    for elem in grp:
        _emi[elem.tag] = _parseEntry_emi(elem.text)

    // Experimental Description
    grp = root.find('ExperimentalDescription/Root')

    for elem in grp:
        _emi['{} [{}]'.format(elem.findtext('Label'), elem.findtext('Unit'))] = _parseEntry_emi(
            elem.findtext('Value'))

    // AcquireInfo
    grp = root.find('AcquireInfo')

    for elem in grp:
        _emi[elem.tag] = _parseEntry_emi(elem.text)

    // DetectorRange
    grp = root.find('DetectorRange')

    for elem in grp:
        _emi['DetectorRange_' + elem.tag] = _parseEntry_emi(elem.text)

    return _emi

}
} */
/*
def _parseEntry_emi(value):
    /*Auxiliary function to parse string entry to int, float or np.string_().
    Parameters
    ----------
        value : str
            String containing an int, float or string.
    Returns
    -------
        : int or float or str
            Entry value as int, float or string.
    */

    // try to parse as int
    try:
        p = int(value)
    except ValueError:
        // if not int, then try float
        try:
            p = float(value)
        except ValueError:
            // if neither int nor float, stay with string
            p = np.string_(str(value))

    return p


def serReader(filename):
    /*Simple function to parse the file and read all datasets. This is a one function implementation to load all data
     in a ser file.
    Parameters
    ----------
        filename : str
            The filename of the SER file containing the data.
    Returns
    -------
        dataOut : dict
            A dictionary containing the data and meta data.
            The data is accessed using the 'data' key and is a 1, 2, 3, or 4
            dimensional numpy ndarray.
    Examples
    --------
        Load a single image data set and show the image:
            >>> import ncempy.io as nio
            >>> ser1 = nio.ser.serReader('filename_1.ser')
            >>> plt.imshow(ser1['data'])  // show the single image from the data file
    */
    // Open the file and init the class
    with fileSER(filename) as f1:
    if f1.head['ValidNumberElements'] > 0{
            // Get the first data set to setup the arrays
            data, metaData = f1.getDataset(0)

            metaData['filename'] = filename  // save the file name in the output dictionary

            npType = f1._dictDataType[metaData['DataType']]

            if f1.head['DataTypeID'] == 0x4120:
                // Spectra as 1D single spectra, 2D line scan or 3D spectrum image
                numSpectra = f1.head['ValidNumberElements']
                spectraSize = data.shape[0]

                // Read in all spectra
                temp = np.zeros((numSpectra, spectraSize), dtype=npType)  // C-style ordering
                for ii in range(0, numSpectra):
                    data0, meta1 = f1.getDataset(ii)
                    temp[ii, :] = data0

                if f1.head['NumberDimensions'] > 1:
                    // Spectrum map
                    scanI = f1.head['Dimensions'][0]['DimensionSize']
                    scanJ = f1.head['Dimensions'][1]['DimensionSize']
                    temp = temp.reshape((scanJ, scanI, spectraSize))  // operations on spectra are fastest
                else:
                    temp = np.squeeze(temp)

                // Setup the energy loss axis for convenience
                eDelta = metaData['Calibration'][0]['CalibrationDelta']
                eOffset = metaData['Calibration'][0]['CalibrationOffset']
                eLoss = np.linspace(0, (spectraSize - 1) * eDelta, spectraSize) + eOffset

                dataOut = {'data': temp, 'eLoss': eLoss, 'eOffset': eOffset, 'eDelta': eDelta,
                           'scanCalibration': f1.head['Dimensions']}
            elif f1.head['DataTypeID'] == 0x4122:
                // Images as 2D or 3D image series
                temp = np.empty([f1.head['ValidNumberElements'], data.shape[0], data.shape[1]], dtype=npType)
                for ii in range(0, f1.head['ValidNumberElements']):
                    data0, metadata0 = f1.getDataset(ii)
                    temp[ii, :, :] = data0  // get the next dataset

                temp = np.squeeze(temp)  // remove singular dimensions

                dataOut = {'data': temp, 'pixelSize': [], 'pixelUnit': [], 'pixelOrigin': []}

                // Setup some simple meta data

                for cal in metaData['Calibration']:
                    dataOut['pixelSize'].append(cal['CalibrationDelta'])
                    dataOut['pixelOrigin'].append(cal['CalibrationOffset'])
                    dataOut['pixelUnit'].append('m')
                dataOut['filename'] = filename  // save the file name
    }
            // Add experimental metadata, if exists
            if f1._emi:
                dataOut['metadata'] = f1._emi
        else:
            dataOut = {}
            print('No data set found')
    return dataOut
    
}
*/
