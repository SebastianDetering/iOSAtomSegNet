//
//  PickerView.swift
//  SwiftUISegNet
//
//  Created by sebi d on 10/15/21.
//

import SwiftUI

struct PickerView: View {
        @State private var selectedColorIndex = 0 // <1>
        var body: some View {
            VStack {
                Picker("Favorite Color", selection: $selectedColorIndex, content: { // <2>
                    Text("Red").tag(0) // <3>
                    Text("Green").tag(1) // <4>
                    Text("Blue").tag(2) // <5>
                })
                Text("Selected color: \(selectedColorIndex)") // <6>
            }
        }
}

struct PickerView_Previews: PreviewProvider {
    static var previews: some View {
        PickerView()
    }
}
