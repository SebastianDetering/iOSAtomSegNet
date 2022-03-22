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
//            GalleryTypeButton(text: "dm3 files",
//                              systemName: "doc.text.fill",
//                              galleryType: .DM3Gallery,
//                              gallerySelection: $gallerySelection)
//                .onTapGesture {
//                    self.gallerySelection = .DM3Gallery
//                }
        }
    }
}
