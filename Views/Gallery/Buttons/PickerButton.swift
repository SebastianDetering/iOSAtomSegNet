//
//  PickerButton.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 12/20/21.
//

import SwiftUI

struct PickerButton: View {
    
    var description: String
    @Binding var selectedItem: MLModels
    
    var body: some View {
        
            NavigationView {
                NavigationLink(destination: ModelPickerView(currentModel: $selectedItem) ) {
                    
                    HStack{
                Text( selectedItem.rawValue )
                    .foregroundColor(.secondary)
                    .font(.system(size: 18, weight: .light, design: .default))
                    .navigationTitle( description )
                    .navigationBarTitleDisplayMode(.large)

                Image( systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    }

                }
            }
            }
        
    
}

struct PickerButton_Previews: PreviewProvider {
    static var previews: some View {
        PickerButton(description: "Models", selectedItem: .constant(.gaussianMask))
    }
}
