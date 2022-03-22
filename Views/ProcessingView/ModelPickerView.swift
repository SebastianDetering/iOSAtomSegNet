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
            HStack {
            Text("model")
                .padding(.leading, 10)
                .foregroundColor(.primary)
            Spacer()
        
                Picker( selection: $currentModel, label: HStack{ Text(currentModel.rawValue);  Image(systemName: "chevron.up")}){
                    ForEach(MLModels.allCases, id: \.self) {
                        Text( $0.rawValue ).tag( $0 )
                    }
            } .pickerStyle(MenuPickerStyle())
                    .foregroundColor(.red)
                       
                Spacer()
            }.frame(width: 400, height: 60, alignment: .trailing)
                .background(Color(.systemBackground))
                .cornerRadius(4)
        }
}



