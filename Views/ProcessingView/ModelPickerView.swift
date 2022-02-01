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

struct PickerView_Previews: PreviewProvider {
    static var previews: some View {
        ModelPickerView(currentModel: .constant(MLModels.gaussianMask))
    }
}
