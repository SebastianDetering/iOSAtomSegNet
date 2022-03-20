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
    
    @StateObject var homeVM: HomeTabViewModel
    @StateObject var processingViewModel: ProcessingViewModel
    @State var gallerySelection: GalleryTabs = .ImageGallery

    let persistenceController = PersistenceController.shared
        
    var body: some View {
            VStack {
                SegNetTabPickerView(gallerySelection: $gallerySelection)
                    .padding(.top, 50)
                if gallerySelection == .ImageGallery {
                    ImageGalleryView(homeVM: homeVM,
                                     processingViewModel: processingViewModel)
                        .environment(\.managedObjectContext,
                                     persistenceController.container.viewContext)
                } else if gallerySelection == .SerGallery {
                    SerGalleryView()
                } else if gallerySelection == .DM3Gallery {
                    Text("Dm3 file coming soon")
                }
            } .background(Color.brandBackground)

    }
}

