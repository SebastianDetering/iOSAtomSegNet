import SwiftUI

final class GalleryViewModel: ObservableObject {
    
    @Published var workingImage: CGImage?
    @Published var imageInProcessing = false
    
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]
}
