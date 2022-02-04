import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    @Binding var isShowing: Bool
    
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
                
                if provider.canLoadObject(ofClass: UIImage.self) {
                    provider.loadObject(ofClass: UIImage.self) { image, _ in
                        self.parent.image = image as? UIImage
                        var newGalIm = GalleryImage(name: image?.debugDescription ?? "", uiimage: self.parent.image)
                        exampleImages.append(newGalIm)
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
