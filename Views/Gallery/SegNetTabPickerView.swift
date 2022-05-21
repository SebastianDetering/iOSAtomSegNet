import SwiftUI

struct SegNetTabPickerView: View {
    @Binding var gallerySelection: GalleryTabs
    
    var body: some View {
        HStack {
            GalleryTypeButton(text: "images",
                              systemName: "photo",
                              galleryType: .ImageGallery,
                              gallerySelection: $gallerySelection)
                .onTapGesture {
                    self.gallerySelection = .ImageGallery
                }
            GalleryTypeButton(text: "ser files",
                              systemName: "doc.text",
                              galleryType: .SerGallery,
                              gallerySelection: $gallerySelection)
                .onTapGesture {
                    self.gallerySelection = .SerGallery
                }
//            GalleryTypeButton(text: "emi files",
//                              systemName: "doc.text.fill",
//                              galleryType: .EmiGallery,
//                              gallerySelection: $gallerySelection)
//                .onTapGesture {
//                    self.gallerySelection = .EmiGallery
//                }
            GalleryTypeButton(text: "about",
                              systemName: "info.circle",
                              galleryType: .AppInfo,
                              gallerySelection: $gallerySelection)
                .onTapGesture {
                    self.gallerySelection = .AppInfo
                }
        }
    }
}
