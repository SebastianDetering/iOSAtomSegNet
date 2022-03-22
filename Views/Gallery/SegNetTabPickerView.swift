import SwiftUI

struct SegNetTabPickerView: View {
    @Binding var gallerySelection: GalleryTabs
    
    var body: some View {
        HStack {
            GroupBox {
        HStack {
            Image(systemName: "photo")
                .foregroundColor(gallerySelection == .ImageGallery ? Color.red : Color.black)
            Text("images")
        }
            }
        .onTapGesture {
            self.gallerySelection = .ImageGallery
        }
            GroupBox {
        HStack {
            Image(systemName: "doc.text")
                .foregroundColor(gallerySelection == .SerGallery ? Color.red : Color.black)
            Text("ser files")
        }
            }
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
