import SwiftUI

struct ImageGalleryView: View {
    
    @StateObject var viewModel: GalleryViewModel
    @StateObject var processingViewModel: ProcessingViewModel
    
    var body: some View {
        ZStack {
            
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: viewModel.columns) {
                        ForEach(exampleImages) { galleryImage in
                            
                            ImageView(imageName: galleryImage.name)
                                .padding(.bottom, 10)
                                .onTapGesture {
                                    $processingViewModel.newSourceImage( sourceType: SegNetDataTypes.Images, imageName: galleryImage.name)
                                }
                        }
                    }
                }
            }
            .sheet(isPresented: $processingViewModel.imageInProcessing) {
                ImageInspectView(cgImageSource: $processingViewModel.sourceImage, imageDidLoad: $processingViewModel.sourceImageLoaded, isShowingView: $processingViewModel.imageInProcessing )
            }
        }
    }
}
    
struct ImageView: View {
    let imageName: String
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .frame(width: 100, height: 100)
                .padding()
            Text(imageName)
                .font(.caption)
        }
    }
}
