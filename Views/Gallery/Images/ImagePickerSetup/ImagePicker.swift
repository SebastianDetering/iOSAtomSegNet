import PhotosUI
import SwiftUI

enum ImportStatuses {
    case NoImport
    case Success
    case Denied
}
struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var imageName: String?
    @Binding var image: UIImage?
    
    @Binding var isShowing: Bool
    @Binding var hasImported: Bool
    @Binding var importStatus: ImportStatuses
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            let authorization = PHPhotoLibrary.authorizationStatus()
            switch authorization {
            case .authorized:
                picker.dismiss(animated: true)
                
                guard let provider = results.first?.itemProvider else { return }
                
                self.parent.image = nil
                if provider.canLoadObject(ofClass: UIImage.self) {
                    provider.loadObject(ofClass: UIImage.self) { image, _ in
                        guard let importedImage = image as? UIImage  else {
                            self.parent.hasImported = false
                            self.parent.isShowing = false
                            return
                        }
                        if let importName = results.first?.itemProvider.suggestedName {
                        self.parent.imageName = importName
                        }
                        self.parent.image = importedImage
                        // publishing changes from background not allowed warning
                    }
                } else {
                    self.parent.importStatus = .Denied
                }
                parent.isShowing = false
            case .limited:
                // iOS 15 we never reached the case for limited... selected was able to see all, just not access certain photos, so the
                // app doesn't know what the possible photos are, and is in the 'authorized' state after selected photos is picked
                picker.dismiss(animated: true)
                
                guard let provider = results.first?.itemProvider else { return }
                
                self.parent.image = nil
                if provider.canLoadObject(ofClass: UIImage.self) {
                    provider.loadObject(ofClass: UIImage.self) { image, _ in
                        guard let importedImage = image as? UIImage  else {
                            self.parent.hasImported = false
                            self.parent.isShowing = false
                            return
                        }
                        if let importName = results.first?.itemProvider.suggestedName {
                        self.parent.imageName = importName
                        }
                        self.parent.image = importedImage
                        // publishing changes from background not allowed warning
                    }
                }
                parent.isShowing = false
            default:
                print("other case \(authorization.rawValue)")
                parent.isShowing = false
            }
            parent.isShowing = false
        }
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
}

//MARK: source https://www.youtube.com/watch?v=-4wBQSr-3yo
