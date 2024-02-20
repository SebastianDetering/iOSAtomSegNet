import PhotosUI
import SwiftUI

struct ImageActionsView: View {
    @State var importedImage: UIImage? = nil
    @Binding var isImportViewShowing: Bool
    @Binding var isPermissionsShowing: Bool
    var parent: ImageGalleryView
    
    var body: some View{
        HStack {
            Button(action: {
                let authorization = PHPhotoLibrary.authorizationStatus()
                print("switching on image authorization status: \(authorization)")
                switch authorization {
                case .notDetermined:
                    parent.homeVM.showingPermissionsSelector = true
                case .restricted:
                    parent.homeVM.showingPermissionsSelector = true
                case .denied:
                    parent.homeVM.showingPermissionsSelector = true
                case .authorized:
                    parent.homeVM.showingImagePicker = true
                case .limited:
                    print("reached limited auth case (in iOS 14 and 15 I haven't reached this)")
                    parent.homeVM.showingImagePicker = true
                @unknown default:
                    print("unhandled authorization status")
                    break
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
