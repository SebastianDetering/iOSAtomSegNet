//
//  RunInferenceButton.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 12/26/21.
//

import SwiftUI

struct RunInferenceButtonLabel: View {
    
    
    var body: some View {
    
            HStack {
                Text("run inference")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.accentColor)
                Image(systemName: "gearshape.2.fill")
                    .foregroundColor(.accentColor)
            }
            .padding(4)
            .background(Color(.label))
            .cornerRadius(2)
        
    }
}

