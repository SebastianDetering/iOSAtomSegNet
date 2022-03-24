import PhotosUI
import SwiftUI

struct TestLimitedLibraryPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: uiViewController)
                DispatchQueue.main.async {
                    isPresented = false
                }
            }
    }

}
