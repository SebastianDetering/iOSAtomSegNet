//
//  PickerView.swift
//  SwiftUISegNet
//
//  Created by sebi d on 10/15/21.
//

import SwiftUI

struct ModelPickerView: View {
    
    @Binding var currentModel: MLModels
    
        var body: some View {
            Picker(selection: $currentModel, label:  ModelPickerLabelView(currentModel: $currentModel)  ){
                    ForEach(MLModels.allCases, id: \.self) {
                        Text( $0.rawValue ).tag( $0 )
                    }
            } .pickerStyle(MenuPickerStyle())
        }
}

struct ModelPickerLabelView: View {
    @Binding var currentModel: MLModels
    var body: some View {
        HStack{ Text(currentModel.rawValue); Image(systemName: "chevron.up") }
    }
}

//HStack{
//    Text("current model")
//        .padding(.leading, 10)
//        .foregroundColor(.primary)
//    Spacer()
//    ModelPickerView(currentModel: $processingVM.currentModel)
//        .foregroundColor(.secondary)
//        .padding(.trailing, 10)
//}.frame(width: 400, height: 60, alignment: .trailing)
//    .background(Color(.systemBackground))
//    .cornerRadius(4)
