import SwiftUI

struct ImageGalleryView: View {
    
    @StateObject var homeVM: HomeTabViewModel
    @StateObject var processingViewModel: ProcessingViewModel
    @StateObject var viewModel = GalleryViewModel()
    
    var body: some View {
        VStack {
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
            ImageActionsView(isImportViewShowing: $homeVM.showingImagePicker, isPermissionsShowing: $homeVM.showingPermissionsSelector)
                .padding(.bottom, 10)
        }
    }
}

struct ImageActionsView: View {
    @State var importedImage: UIImage? = nil
    @Binding var isImportViewShowing: Bool
    @Binding var isPermissionsShowing: Bool
    
    var body: some View{
        HStack {
            
            Button(action: {
                isImportViewShowing = true
                isPermissionsShowing = true
            },
                   label: {
                    HStack{
                        Text("Camera Roll")
                Image(systemName: "photo.on.rectangle.angled")
                    }
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
