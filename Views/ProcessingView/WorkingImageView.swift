//
//  ImageSourceView.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 12/21/21.
//

import SwiftUI

struct WorkingImageView: View {
    @Binding var tabSelection: HomeTabs
    @Binding var gallerySelection: GalleryTabs // we want to go to image gallery when tapping "select image"

    var workingImage: CGImage?
    @Binding var imageInProcessing: Bool
    
    var body: some View {
        if workingImage != nil {
            Image( uiImage: UIImage(cgImage: workingImage!) ) // should have viewModel.workingImage passed in
                .resizable()
                .frame(width: 230, height: 230)
        } else {
            ZStack{
                Rectangle()
                    .frame(width: 230, height: 230, alignment: .center)
                    .foregroundColor(.brandPrimary)
                Button(action:{imageInProcessing = false;tabSelection = .Gallery;gallerySelection = .ImageGallery},
                       label: {Text("select image to process")} )
                    .frame(width: 230, height: 230, alignment: .center)
                    .foregroundColor(.accentColor)
            }
        }
    }
}
