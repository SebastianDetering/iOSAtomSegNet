//
//  GalleryView.swift
//  SwiftUISegNet
//
//  Created by sebi d on 9/12/21.
//

import SwiftUI

enum GalleryTabs {
    case ImageGallery
    case SerGallery
    case DM3Gallery
}

struct GalleryView: View {
    
    @StateObject var viewModel = GalleryViewModel()
    @StateObject var processingViewModel: ProcessingViewModel
    @Binding var tabSelection: HomeTabs
    @State var gallerySelection: GalleryTabs = .ImageGallery
    
    var body: some View {
        VStack {
            VStack {
                SegNetTabPickerView(gallerySelection: $gallerySelection)
                    .padding(.top, 50)
                if gallerySelection == .ImageGallery {
                    ImageGalleryView(viewModel: viewModel, processingViewModel: processingViewModel)
                           } else if gallerySelection == .SerGallery {
                               SerGalleryView()
                           } else if gallerySelection == .DM3Gallery {
                               Text("Dm3 file coming soon")
                           }
        }
        }
    }
}
