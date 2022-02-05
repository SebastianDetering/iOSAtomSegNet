import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    @Binding var isShowing: Bool
    @Binding var hasImported: Bool
    
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
                        self.parent.image = importedImage
                        
                    }
                }
                
                parent.isShowing = false

            case .limited:
               print("Probably want to add more photos in this case")
            default:
                print("other case \(authorization.rawValue)")
                parent.isShowing = false
            }
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
