//
//  Ser-Classes-Structs.swift
//  Ser-Reader
//
//  Created by sebi d on 14.6.21.
//
// MARK: source  https://github.com/ercius/openNCEM/blob/e304d565870bdb32f76abc0adc0c937cf6947ebc/ncempy/io/ser.py

import Foundation
// for complex numbers
import Accelerate

class NotSERError : NSError {
    required init(coder : NSCoder){
        super.init(coder: coder)!
    }
}

class fileSer {
    let _dictByteOrder : [Int16: String] = [ 0x4949 : "little endian" ]
    // dict : Information on byte order.//
    let _dictSeriesVersion : [Int16:String] = [0x0210: "< TIA 4.7.3", 0x0220: ">= TIA 4.7.3"]
        //dict : Information on file format version.//

    let _dictDataTypeID : [Int32: String] = [0x4120: "1D datasets", 0x4122: "2D images"]
        //dict : Information on data type.//

    let _dictTagTypeID : [Int32 : String] = [0x4152: "time only", 0x4142: "time and 2D position"]
        //dict : Information on tag type.//

    let _dictDataType : [Int16 : Any ] = [ 1: "<u1", 2: "<u2", 3: "<u4", 4: "<i1", 5: "<i2", 6: "<i4", 7: "<f4", 8: "<f8", 9: "<c8",
                                        10: "<c16" ] // these are identical to np.fromfile arguments... file-Read.swift will use this
        //dict : Information on data format.//
    
    var head : [String:Any]?
    
    var filename : String?
    
    var _file_hdl : fRead?

    var offset : Int = 0 // since
    
    var data : [Any]? // the dynamic variable which will store raw data, in many types. Used in readHeader(), and practically every other function
    
    init(filename : Any?, verbose : Bool = false ) {

        // necessary declarations, if something fails
        self._file_hdl = nil
            //  self.emi = nil
        self.head = nil
        // check filename type
        
        self.filename = filename as? String
           
        if type(of : self.filename) == URL?.self {
            self.filename = (filename as! URL).absoluteString
        }
        else if type(of : self.filename) == String?.self { }
        else { fatalError("TypeError: filename is supposed to be a string or Swift 5 URL, not \(type(of : self.filename))")}
       
        // try opening the file
        do
        {
            self._file_hdl = fRead( data : try Data(contentsOf: URL(fileURLWithPath: self.filename ?? "")))
        }
        catch {
            fatalError("Error reading file: \(self.filename)")
        }
        
        // self.head = self.readHeader(verbose : true)
        
        // self.read_emi()
    }

    
    private func __del__() {
        // close the file stream in destructor.
        if self._file_hdl?.closed != false {
                try self._file_hdl?.close()
        }
    }
    
    private func enter() -> fileSer {
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

    func readHeader(verbose : Bool = false) -> [String:Any]? {
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
        var head : [String:Any]? = [:]

        // go back to beginning of file
        self._file_hdl?.resetOffsetToZero()
            
            // read 3 int16
        data = (self._file_hdl?.fromfile(dtype: "<i2", count: 3) as? [Int16])!
            // ByteOrder (only little Endian expected)
        if let data : [Int16] = data as? [Int16] {
        if !(self._dictByteOrder.keys.contains(data[0])) {
        fatalError("Only little Endian implemented for SER files")
            }       // head['ByteOrder'] = data[0]
        if verbose {
            print("ByteOrder:\(data[0] as! Int16),\(String(describing: self._dictByteOrder[data[0] as! Int16]))")
            }
            
            // SeriesID, check whether TIA Series Data File
        if data[1] != 0x0197 {
            NotSERError(coder : NSCoder())
            fatalError("The file is not TIA Series Data File")
                return nil
        }
        head!["SeriesID"] = data[1]
        
    
        if verbose {
            print("SeriesID:\t \(data[0]) \tTIA Series Data File")
        }
        // SeriesVersion
        if !self._dictSeriesVersion.keys.contains(data[2] ) {
            fatalError( "Unknown TIA version: \(String(data[2]) )")
        }
        head!["SeriesVersion"] = data[2]
        if verbose{
            print(String(format: "SeriesVersion:\t %@,\t \(String(describing: _dictSeriesVersion[ data[2] ]))", String(data[2]) ))
        }
        }
        else { fatalError("During header parsing data couldn't be made into Int16.")}
        
        // MARK: version dependent file format for below ( important line is here for int64 )
        let offset_dtype : String
        if head!["SeriesVersion"] as! Int16 == 0x0210 {
            offset_dtype = "<i4"
        }
        else {
            // head['SeriesVersion']==0x220:
            offset_dtype = "<i8" }

        // read 4 int32
        data = _file_hdl!.fromfile(dtype : "<i4", count : 4) as! [Int32]

        // DataTypeID
        if let data : [Int32] = data as? [Int32] {
            if !self._dictDataTypeID.keys.contains(data[0]) {
            fatalError("Unknown DataTypeID: \(data[0])")
            }
            head!["DataTypeID"] = data[0]
            if verbose {
                print( String(format: "DataTypeID:\t %@,\t %@", String(data[0]), self._dictDataTypeID[data[0]]!))
            }
        // TagTypeID
            if !self._dictTagTypeID.keys.contains(data[1]) {
            fatalError("Unknown TagTypeID:\(data[1])")
            }
            head!["TagTypeID"] = data[1]
            if verbose {
            print(String(format: "DataTypeID:\t %@,\t %@", String(data[1]), String(describing: self._dictDataTypeID[data[1]])))
            }
        // TotalNumberElements
            if !(data[2] >= 0){
                fatalError("Negative total number of elements: \(data[2])")
            }
            head!["TotalNumberElements"] = data[2]
            if verbose {
                print("TotalNumberElements:\(data[2])")
            }
        // ValidNumberElements
            if !(data[3] >= 0){
            fatalError("Negative valid number of elements: \(String(data[3]))")
            }
            head!["ValidNumberElements"] = data[3]
            if verbose{
            print("ValidNumberElements:\(String(data[3]))")
            }
        }
        else { fatalError("During header parsing data couldn't be made into Int32.")}
        // OffsetArrayOffset, sensitive to SeriesVersion
        data = _file_hdl!.fromfile(dtype : offset_dtype, count : 1)
        head!["OffsetArrayOffset"] = data![0]
        if verbose{
            print("OffsetArrayOffset:\(data![0])")
        }

        // NumberDimensions
        data = _file_hdl!.fromfile(dtype : "<i4", count : 1)
        if !(data![0] as! Int32 >= 0){
            fatalError("Negative number of dimensions")
        }
        head!["NumberDimensions"] = data![0]
        if verbose {
            print("NumberDimensions:\(data![0])")
        }
        // Dimensions array
        var dimensions : [Any] = [] // set type

        for i in 0...(head!["NumberDimensions"] as! Int32) {
            if verbose{
                print("reading Dimension \(i)")
            }
            var this_dim : [String: Any] = [:] // set type

            // DimensionSize
            data = _file_hdl!.fromfile(dtype : "<i4")
            this_dim["DimensionSize"] = data![0] as? Int32
            if verbose{
                print("DimensionSize:\(data![0])")
            }
            data = _file_hdl!.fromfile(dtype : "<f8", count : 2)

            // CalibrationOffset
            this_dim["CalibrationOffset"] = data![0] as! Float64
            if verbose{
                print("CalibrationOffset:\(data![0])")
            }
            // CalibrationDelta
            this_dim["CalibrationDelta"] = data![1] as! Float64
            if verbose {
                print("CalibrationDelta:\(data![1])")
            }
            data = _file_hdl!.fromfile(dtype : "<i4", count : 2)

            // CalibrationElement
            this_dim["CalibrationElement"] = data![0] as! Int32
            if verbose{
                print("CalibrationElement:\(data![0])")
            }
            // DescriptionLength
            var n = data![1] as! Int32
            
            // Description
            data = _file_hdl!.fromfile(dtype: "<i1", count : Int(littleEndian: Int(n)) )
           // data = ''.join(map(chr, data))
            this_dim["Description"] = data
            if verbose{
                print("Description:\(data!)")
            }
            // UnitsLength
            data = _file_hdl!.fromfile(dtype : "<i4", count : 1)
            n = data![0] as! Int32

            // Units
            data = _file_hdl!.fromfile(dtype:"<i1", count : Int(littleEndian: Int(n) ))
            //data = ''.join(map(chr, data))
            this_dim["Units"] = data!
            if verbose{
                print("Units:\(String(describing: data))")
            }
            dimensions.append(this_dim)
        }
        // save dimensions array as tuple of dicts in head dict
        head!["Dimensions"] = dimensions // tuple(dimensions) in python, (see if this will do the same thing).

        // Offset array
        // MARK: the problem with this that the type is not determined and Any can't be unwrapped to Int (look up out how to do this).
        if let unwrappedOffsetArrayOffset = head?["OffsetArrayOffset"]
        {
            print(type(of : unwrappedOffsetArrayOffset))
            let unwrappedOffsetArrayOffsetStr = String(unwrappedOffsetArrayOffset as! Int64)
            
            if let unwrappedInt : Int32 = Int32(unwrappedOffsetArrayOffsetStr) {
                print("Offset was set correctly.")
                _file_hdl!.setOffset( Int(unwrappedInt) )
            }
            else { print( "Int conversion of the OffsetArrayOffset \"\(String(describing: head!["OffsetArrayOffset"]))\" failed.")}
        }
        else { fatalError( "Int conversion of the OffsetArrayOffset \"\(String(describing: head!["OffsetArrayOffset"]))\" failed.")}

      
        // DataOffsetArray
        data = _file_hdl!.fromfile(dtype: offset_dtype, count : Int(head!["ValidNumberElements"] as! Int32))
        head!["DataOffsetArray"] = data // .tolist() in python, (but it is already list?)
        if verbose{
            print("reading in DataOffsetArray")
        }
        // TagOffsetArray
        
        // MARK: possibly the tag offset array is wrong, making everything off.
        data = _file_hdl!.fromfile(dtype : offset_dtype, count : Int(head!["ValidNumberElements"] as! Int32))
        head!["TagOffsetArray"] = data // .tolist() in python, (but it is already list?)
        if verbose {
            print("reading in TagOffsetArray")
        }
        //data = nil // clear data variable (not existent in python code)
        self.head = head
        return head
    }


    func _checkIndex(i : Any?) throws {
        /* Check index i for sanity, otherwise raise Exception.
        Parameters
        ----------
            i: int
                Index.
        */

        // check type (is implicit in getDataset(index: Int) - swift is often specific while python isnt.)
        if type(of: i) == Int.self {
            fatalError("index supposed to be integer")
        }
        
        // check whether in range
        guard let validElemsUnwrapped = self.head?["ValidNumberElements"] else { return}
        print(validElemsUnwrapped)
        if (i as! Int) < 0 || (i as! Int) >= Int(self.head!["ValidNumberElements"] as! Int32) {
            fatalError(String(format: "Index out of range accessing element %@ of %@ valid elements", i as! Int + 1, self.head?["ValidNumberElements"]! as! CVarArg))
        }
        return
    }
    func getDataset(index : Int, verbose : Bool = false) -> [Any] {
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

        // check index, will raise Exceptions if not
        do {
            try self._checkIndex(i: index)
        }
        catch {  } // Throwing errors would be done in the _checkIndex() function..

        if verbose {
            print(String(format: "Getting dataset %@ of %@.", index, self.head!["ValidNumberElements"] as! CVarArg))
        }
        // go to dataset in file
        //MARK: will have same issue that is unresolved earlier with unwrapping.
        print()
        guard let dataOffsetArrayUnwrap = self.head?["ValidNumberElements"] else {return [] }
        self._file_hdl?.setOffset(Int(dataOffsetArrayUnwrap as! Int32))

        // read meta
        var meta : [String:Any] = [:]
        var n = 1
        // number of calibrations depends on DataTypeID
        guard let dataTypeIDUnwrap = self.head?["DataTypeID"] else { fatalError("DataTypeID unwrap failed") }
        print(type( of : dataTypeIDUnwrap))
        guard let dataTypeIDInt = dataTypeIDUnwrap as? Int32 else { fatalError("type conversion failed") }
        if Int(dataTypeIDInt) == 0x4120 {
            n = 1
        }
        else if Int(dataTypeIDInt) == 0x4122 {
            n = 2
        }
        else{
            fatalError("Unknown DataTypeID")
        }

        // read in the calibrations
        var cals : [Any] = []
        for i in 0..<n {
            if verbose {
                print("Reading calibration \(i)")
            }
            var this_cal : [String: Any ] = [:]

            data = _file_hdl!.fromfile(dtype : "<f8", count : 2)
            print(data)
            // CalibrationOffset
            this_cal["CalibrationOffset"] = data![0]
            if verbose {
                print("CalibrationOffset:\t\(data![0])")
            }
            // CalibrationDelta
            this_cal["CalibrationDelta"] = data![1] as! Float64
            if verbose {
                print("CalibrationDelta:\t\(data![1])")
            }
            data = _file_hdl!.fromfile(dtype : "<i4", count : 1)
            print(data)
            // CalibrationElement
            this_cal["CalibrationElement"] = data![0] as! Int32
            if verbose{
                print("CalibrationElement:\(data![0])")
            }
            cals.append(this_cal)
        }
        meta["Calibration"] = cals // tuple(cals) in python

        data = _file_hdl!.fromfile(dtype: "<i2", count:1)

        // DataType
        meta["DataType"] = data![0] as! Int16

        if !self._dictDataType.keys.contains(data![0] as! Int16){
           // MARK: Something is going wrong with this guy, for now, I am defaulting to Int32 "<i4"
            //fatalError("Unknown DataType: \(data![0])")
            meta["DataType"] = 6 as Int16
        }
        if verbose {
            if let dataInt = data![0] as? Int16 {
                print( String(format: "DataType:\t%@,\t%@", dataInt, String(describing: _dictDataType[dataInt ]) ) )
            }
            else { fatalError("couldn't turn \(String(describing: data?[0])) into Int")}
        }
        var  dataset : [Any]? = nil  // in case something goes wrong (serves as initialization of this variable in swift)

        guard let DataTypeIDUnwrap = self.head!["DataTypeID"] else { fatalError("header DataTypeID Unwrapping failed")}
        print(type(of : DataTypeIDUnwrap))
        guard let DataTypeIDUnwrapInt = DataTypeIDUnwrap as? Int32 else { fatalError("header DataTypeID conversion to Int32 failed") }
        
        guard let dataTypeString = meta["DataType"] as? Int16 else {fatalError("meta[\"DataType\"] couldn't be read as Int16.")}
        print(dataTypeString, _dictDataType)
        guard let fileDType = _dictDataType[dataTypeString] else { fatalError("_dictDataType[meta[\"DataType\"]] couldn't be converted to string.")}
        guard let fileDTypeStr = fileDType as? String else { fatalError("couldn't parse file _dictDataType[Meta[\"DataType\"]] to string.")}
        
        if Int(DataTypeIDUnwrapInt) == 0x4120 {
            // 1D data element
        print("1D data element")
            data = _file_hdl!.fromfile(dtype: "<i4", count:1)
            // ArrayLength
           // data = data  //tolist() in python but it is already a list...
            meta["ArrayShape"] = data
            if verbose{
                print("ArrayShape:\t\(data)")
            }
        
        
        // workaround : test what meta["DataType"] is, then switch on the datatype such that swift knows what type dataset will be.
        
            var cast : Any
            switch _dictDataType[ dataTypeString ] as! String {
            case "<i4":
                dataset = _file_hdl!.fromfile(dtype : "<i4",
                                              count : (meta["ArrayShape"] as! [Int])[0]) as! [Int32]
            case "<i8":
                dataset = _file_hdl!.fromfile(dtype : "<i8",
                                              count : (meta["ArrayShape"] as! [Int])[0]) as! [Int64]
            default :
                cast = [Int].self
            }
           // not sure if switching will be the best way...
        } else if Int(DataTypeIDUnwrapInt) == 0x4122 {
            // 2D data element
            print("2D data element")
            data = _file_hdl!.fromfile( dtype : "<i4", count : 2) as! [Int32]
            print(data)
            // ArrayShape
//            data = data.tolist() // not necessary because it's already a list/Swift Array.
            meta["ArrayShape"] = data
        }
        
        
        if verbose{
                print("ArrayShape:\t\(data)")
        }
        
        guard let arrayShape = meta["ArrayShape"] as? [Int32] else {
            if verbose {
                fatalError("error parsing header attribute \"arrayShape\" as Int32")
            } else { }
            return []
        }
        // MARK: I'm going to switch the data types... can't figure out a better way.
        // dataset
        
        print(arrayShape)
        switch fileDTypeStr {
            case "<i2":
                guard var datasetFinalType : [Int16] =  _file_hdl!.fromfile(dtype: "<i2", count : Int(arrayShape[0] * arrayShape[1]) ) as? [Int16]
                else{
                    fatalError("problem getting data into form [Int16] using method fromfile(dtype:, arrayShape:)" )
                }
                datasetFinalType.reverse()
                return [datasetFinalType, meta]
                
            case "<i4":
                guard var datasetFinalType : [Int32] =  _file_hdl!.fromfile(dtype: "<i4", count : Int(arrayShape[0] * arrayShape[1]) ) as? [Int32]
                else{
                    fatalError("problem getting data into form[Int32] using method fromfile(dtype:, arrayShape:)" )
                }
                datasetFinalType.reverse()
                return [datasetFinalType, meta]
            case "<i8":
                guard var datasetFinalType : [Int64] =  _file_hdl!.fromfile(dtype: "<i8", count : Int(arrayShape[0] * arrayShape[1]) ) as? [Int64]
                else{
                    fatalError("problem getting data into form [Int64] using method fromfile(dtype:, arrayShape:)" )
                }
                datasetFinalType.reverse()
                return [datasetFinalType, meta]
                
            default:
                fatalError("selected dataType is not among the available values.")
                
        }
        
          // needs to be reversed for little endian data // originally had meta["ArrayShape"][::-1] as argument.
        
    //find reverse in Swift.    dataset = ReversedCollection(_base: dataset!)
        }
        
        
    


    func _getTag( index : Int, verbose : Bool = false) -> [String:Any] {
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
        //MARK: again same problem
        self._file_hdl!.setOffset( (head!["TagOffsetArray"] as! [Int] )[index]) // 0 in second argument.

        data = _file_hdl!.fromfile(dtype:"<i4", count:2)

            // TagTypeID
        tag["TagTypeID"] = data![0]
// MARK: Friday notes : use a struct and see which data is to be used.
        
        // output was OptionalValue(72)
        
        // read in Any then convert to double float
        
        guard let tagTypeIDHead = self.head!["TagTypeID"],
              let tagTypeIDTag = tag["TagTypeID"] as? Int
        else { fatalError("TagTypeID was not read correctly as Int")}
            // only proceed if TagTypeID is the same like in the file header (bad TagOffsetArray issue)
        if self.head!["TagTypeID"] as! Int == tagTypeIDTag {
            if verbose{
                if let data0 = data?[0] as? [Int32],
                   let dataTagTypeIdData0 = self._dictTagTypeID[ data0[0] ] {
                print(String(format: "TagTypeID:\t\"%@\",\t\"%@\"", data0 , dataTagTypeIdData0 )) // {://06x} is used in python for further formatting settings
                    }
            }
                // Time
                tag["Time"] = data![1]
            if verbose{
                    print("Time:\t \(data![1])")
            }
                // check for position
            if (tag["TagTypeID"] as! Int) == 0x4142{
                data = _file_hdl!.fromfile(dtype : "<f8", count : 2)

                    // PositionX
                    tag["PositionX"] = data![0]
                if verbose{
                        print("PositionX:\t\(data![0])")
                }
                    // PositionY
                    tag["PositionY"] = data![1]
                if verbose {
                        print("PositionY:\t{}\(data![1])")
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

//    func createDim(size : Int, offset: Int, delta: Int, element: Int) -> [Float64] {
//        /*Create dimension labels for conversion to EMD
//        from information in the SER file.
//        Parameters
//        ----------
//            size: int
//                Number of elements.
//            offset: float
//                Value at indicated element.
//            delta: float
//                Difference between elements.
//            element: int
//                Indicates the element of value offset.
//        Returns
//        -------
//            dim: np.ndarray
//                Dimension vector as array.
//        */
//
//        // if element is out off range, map it back into defined
//        if element >= size {
//            let element = size - 1
//            let offset = offset - (element - (size - 1)) * delta
//        }
//        var dim = [Float64].self.init(repeating: 0, count: size)
//        guard case let Self.dim = Self.dim * delta
//        dim += (offset - dim[element])
//
//        // some weird shifting, positionx is +0.5, positiony is -0.5
//        // doing this during saving
//        // dim += 0.5*delta
//
//        return dim
//    }
//    func _read_emi(){
//        // Generate emi file string
//        // and test for file existence.
//
//        let emi_file = self.filename[:-6] + ".emi"
//        if not os.path.exists(emi_file):
//            self._emi = None
//        else:
//            self._emi = read_emi(emi_file)
//    }
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

def read_emi(filename):
    /*Read the meta data from an emi file.
    Parameters
    ----------
        filename: str or pathlib.Path
            Path to the emi file.
    Returns
    -------
        : dict
            Dictionary of experimental metadata stored in the EMI file.
    */

    // check filename type
    if isinstance(filename, str):
        pass
    elif isinstance(filename, Path):
        filename = str(filename)
    else:
        raise TypeError('Filename is supposed to be a string or pathlib.Path')

    // try opening the file
    try:
        // open file for reading bytes, as binary and text are intermixed
        with open(filename, 'rb') as f_emi:
            emi_data = f_emi.read()
    except IOError:
        print('Error reading file: "{}"'.format(filename))
        raise
    except:
        raise

    // dict to store _emi stuff
    _emi = {}

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
