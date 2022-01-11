//
//  ImageSourceView.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 12/21/21.
//

import SwiftUI

struct ImageSourceView: View {
    @Binding var tabSelection: HomeTabs
    @Binding var sourceImage: CGImage?
    @Binding var imageInProcessing: Bool
    
    var body: some View {
        if sourceImage != nil {
            Image( uiImage: UIImage(cgImage: sourceImage!) ) // should have viewModel.workingImage passed in
                .resizable()
                .frame(width: 230, height: 230)
        } else {
            ZStack{
                Rectangle()
                    .frame(width: 230, height: 230, alignment: .center)
                    .foregroundColor(.brandPrimary)
                Button(action: { imageInProcessing = false; tabSelection = .Gallery}, label: {Text("select image to process")} )
                    .frame(width: 230, height: 230, alignment: .center)
                    .foregroundColor(.accentColor)
            }
        }
    }
}
