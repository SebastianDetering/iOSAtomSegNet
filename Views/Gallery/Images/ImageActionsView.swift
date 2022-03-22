import SwiftUI

struct ImageActionsView: View {
    @State var importedImage: UIImage? = nil
    @Binding var isImportViewShowing: Bool
    @Binding var hasPermission: Bool
    @Binding var isPermissionsShowing: Bool
    var parent: ImageGalleryView
    
    var body: some View{
        HStack {
            Button(action: {
                if hasPermission {
                isImportViewShowing = true
                } else {
                isPermissionsShowing = true
                }
            },
                   label: {
                    Text("Camera Roll")
                    }
                   ) .padding(.trailing, 30)
            
            Button(action: {
                
                parent.getExampleAssets() // put in special settings (user can retrieve assets if deleted accidentally.)
            }, label: {
                Text("example images")
            })
        }
    }
}
