import SwiftUI

struct ImageGalleryView: View {
    
    @StateObject var homeVM: HomeTabViewModel
    @StateObject var processingViewModel: ProcessingViewModel
    @StateObject var viewModel = GalleryViewModel()
    
    var body: some View {
        VStack {
            ImageActionsView(isImportViewShowing: $homeVM.isShowingImportView)
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: viewModel.columns) {
                        ForEach(exampleImages) { galleryImage in
                            
                            ImageView(imageName: galleryImage.name)
                                .padding(.bottom, 10)
                                .onTapGesture {
                                    processingViewModel.newSourceImage( sourceType: SegNetDataTypes.Images,
                                                                        image: UIImage.init(named: galleryImage.name)?.cgImage,
                                                                        imageName: galleryImage.name)
                                    processingViewModel.inspectingImage = true
                                }
                        }
                    }
                } .navigationBarHidden(true)
            }
            .sheet(isPresented: $processingViewModel.inspectingImage) {
                ImageInspectView(homeVM: homeVM,
                                 processingVM: processingViewModel)
            }
        }
    }
}

struct ImageActionsView: View {
    @State var importedImage: UIImage? = nil
    @Binding var isImportViewShowing: Bool
    
    var body: some View{
        HStack {
            
            Button(action: {
                isImportViewShowing = !isImportViewShowing
            },
                   label: {
                Image(systemName: "photo.on.rectangle.angled")
            })
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
