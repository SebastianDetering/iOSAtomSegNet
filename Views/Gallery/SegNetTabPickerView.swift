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
//            GroupBox {
//        HStack {
//            Image(systemName: "doc.text.fill")
//                .foregroundColor(gallerySelection == .DM3Gallery ? Color.red : Color.black)
//            Text("dm3 files")
//        }
//            }
        .onTapGesture {
            self.gallerySelection = .DM3Gallery
        }
        }
    }
}
