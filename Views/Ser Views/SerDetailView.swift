//
//  SerDetailView.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 1/27/22.
//

import SwiftUI

struct SerDetailView: View {
    
    @Binding var serHeader: SerHeader
    
    var body: some View {
        VStack {
            SerDetailItem<Int16>(name: "Series ID", tagValue: $serHeader.SeriesID )
            SerDetailItem<Int16>(name: "Series Version", tagValue: $serHeader.SeriesVersion )
            SerDetailItem<Int32>(name: "Data Type ID", tagValue: $serHeader.DataTypeID )
            SerDetailItem<Int32>(name: "Tag Type ID", tagValue: $serHeader.TagTypeID )
            SerDetailItem<Int32>(name: "Total Number Elements", tagValue: $serHeader.TotalNumberElements )
            SerDetailItem<Int32>(name: "Valid Number Elements", tagValue: $serHeader.ValidNumberElements )
            SerDetailItem<Int>(name: "Offset Array Offset", tagValue: $serHeader.OffsetArrayOffset )

            SerDetailItem<Int32>(name: "Number Dimensions", tagValue: $serHeader.NumberDimensions )
//            SerDetailItem<Int>(name: "Datta Offset Array", tagValue: $serHeader.DataOffsetArray )
//            SerDetailItem<Int>(name: "Tag Offset Array", tagValue: $serHeader.TagOffsetArray )
// these are arrays of description.
            //var Dimensions          : [SerDimensionDescriptor] = []
//            var DataOffsetArray     : [Int] = [] // same condition as DataOffsetArray
//            var TagOffsetArray      : [Int] = [] // ibid.
        }
    }
}



struct SerDetailItem<T: BinaryInteger>: View  {
    
    var name: String
    @Binding var tagValue: T
    
    var body: some View {
        HStack {
            Text("\(name)")
                .frame(width: 300, height: 20, alignment: .leading)
                
            Text(String(format:"0x%04X", tagValue as! CVarArg))
                .font(.caption)
        }
    }
}

