//
//  GalleryView.swift
//  SwiftUISegNet
//
//  Created by sebi d on 9/12/21.
//

import SwiftUI

enum GalleryTabs: String {
    case ImageGallery = "images"
    case SerGallery   = "ser files"
    case EmiGallery   = "emi files" // it was hard to code this because string parsing and data parsing was a lot to do, but it certainly is possible with good practice
    case AppInfo      = "about"
}

struct GalleryView: View {
    
    @StateObject var homeVM: HomeTabViewModel
    @StateObject var processingViewModel: ProcessingViewModel

    let persistenceController = PersistenceController.shared
        
    var body: some View {
            VStack {
                SegNetTabPickerView(gallerySelection: $homeVM.gallerySelection)
                    .padding(.top, 50)
                    .frame( alignment: .top)
                if homeVM.gallerySelection == .ImageGallery {
                    ImageGalleryView(homeVM: homeVM,
                                     processingViewModel: processingViewModel)
                        .environment(\.managedObjectContext,
                                     persistenceController.container.viewContext)
                } else if homeVM.gallerySelection == .SerGallery {
                    SerGalleryView(homeVM: homeVM,
                                   processingVM: processingViewModel)
                } else if homeVM.gallerySelection == .EmiGallery {
                    Text("emi file coming soon")
                    Spacer()
                } else if homeVM.gallerySelection == .AppInfo {
                    AppInfoView()
                }
            } .background(Color.brandBackground)

    }
}

