import SwiftUI

struct GalleryTypeButton: View {
    
    var text: String
    var systemName: String
    var galleryType: GalleryTabs
    @Binding var gallerySelection: GalleryTabs
    
    var body: some View {
        GroupBox {
            HStack {
                Image(systemName: systemName)
                    .foregroundColor(gallerySelection == galleryType ? Color.red : Color.black)
                Text(text)
            }
        }
    }
}
