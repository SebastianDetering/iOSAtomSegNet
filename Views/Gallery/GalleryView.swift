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
    case EmiGallery
    case AppInfo
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
                    .frame( alignment: .top)
                if gallerySelection == .ImageGallery {
                    ImageGalleryView(homeVM: homeVM,
                                     processingViewModel: processingViewModel)
                        .environment(\.managedObjectContext,
                                     persistenceController.container.viewContext)
                } else if gallerySelection == .SerGallery {
                    SerGalleryView(homeVM: homeVM,
                                   processingVM: processingViewModel)
                } else if gallerySelection == .EmiGallery {
                    Text("emi file coming soon")
                    Spacer()
                } else if gallerySelection == .AppInfo {
                    AppInfoView()
                }
            } .background(Color.brandBackground)

    }
}

