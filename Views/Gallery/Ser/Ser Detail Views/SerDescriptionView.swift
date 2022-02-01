//
//  SerDetailView.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 1/27/22.
//

import SwiftUI
//human readable header values
struct SerDescriptionView: View {
    
    @Binding var headerDescription: SerHeaderDescription
    
    var body: some View {
        VStack {
            SerDescriptionItem(name: "Series ID",       tagValue:$headerDescription.SeriesID )
            SerDescriptionItem(name: "Series Version", tagValue:$headerDescription.SeriesVersion )
            SerDescriptionItem(name: "Data Type ID",     tagValue:$headerDescription.DataTypeID )
            SerDescriptionItem(name: "Tag Type ID",     tagValue:$headerDescription.TagTypeID )
            SerDescriptionItem(name: "Total Number Elements",    tagValue:$headerDescription.TotalNumberElements )
            SerDescriptionItem(name: "Valid Number Elements", tagValue:$headerDescription.ValidNumberElements )
            SerDescriptionItem(name: "Offset Array Offset",     tagValue:$headerDescription.OffsetArrayOffset )

            SerDescriptionItem(name: "Number Dimensions",   tagValue:$headerDescription.NumberDimensions )
            SerDescriptionItem(name: "Data Offset Array",   tagValue:$headerDescription.DataOffsetArray )
            SerDescriptionItem(name: "Tag Offset Array",    tagValue:$headerDescription.TagOffsetArray )
// these are arrays of description.
            //var Dimensions          : [SerDimensionDescriptor] = []
//            var DataOffsetArray     : [Int] = [] // same condition as DataOffsetArray
//            var TagOffsetArray      : [Int] = [] // ibid.
        }
    }
}



struct SerDescriptionItem: View  {
    
    var name: String
    @Binding var tagValue: String
    
    var body: some View {
        HStack {
            Text("\(name)")
                .frame(width: 200, height: 20, alignment: .leading)
            Text("\(tagValue)")
                .font(.caption)
        }
    }
}

