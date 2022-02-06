//
//  ModelOutputsView.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 12/21/21.
//

import SwiftUI

struct ModelOutputsView: View {
    @Binding var imageDidProcess: Bool
    @Binding var cgImageOutput: CGImage?
    @Binding var isLoadingActivations: Bool
    
    var body: some View {
        ZStack{
            if imageDidProcess && cgImageOutput != nil {
                Image.init(uiImage: UIImage(cgImage: cgImageOutput!))
                    .resizable()
                    .frame(width: 230, height: 230)
            } else {
                ZStack {
                    Rectangle()
                        .frame(width: 230, height: 230, alignment: .center)
                        .foregroundColor(.brandPrimary)
                }
                if !isLoadingActivations {
                    VStack { Text("neural network outputs")
                        Image(systemName: "cpu")
                    }
                }
            }
            if isLoadingActivations {
                LoadingView()
            }
        }
    }
}
