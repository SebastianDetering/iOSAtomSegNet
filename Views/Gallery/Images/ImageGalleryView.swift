import SwiftUI

struct ImageGalleryView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \GalleryImage.date, ascending: false)])
    
    private var galleryImages: FetchedResults<GalleryImage>
    
    @StateObject var homeVM: HomeTabViewModel
    @StateObject var processingViewModel: ProcessingViewModel
    @StateObject var viewModel = GalleryViewModel()
    
    var body: some View {
        VStack {
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: viewModel.columns) {
                        ForEach(galleryImages) { galleryImage in
                            ImageIconView(galleryImage: galleryImage)
                                .contextMenu {
                                    HStack {
                                        Button {
                                            print("cancel delete \(galleryImage.id)")
                                        } label: {
                                            Label("cancel", systemImage: "trash.slash")
                                        }

                                        Button {
                                            deleteGalleryImage(uId: galleryImage.id)
                                        } label: {
                                            Label("remove image", systemImage: "trash.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    }
                                .onTapGesture {
                                    processingViewModel.newSourceImage( sourceType: SegNetDataTypes.Images,
                                                                        image: UIImage(data: galleryImage.imageData!)?.cgImage!,
                                                                        imageName: galleryImage.name ?? " No name ")
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
        }  .onChange(of: homeVM.importImage) {
            newImage in
            newGalleryImage()
        }
    }
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved Error: \(error)")
        }
    }
    private func newGalleryImage() {
        guard let imageToAdd = homeVM.importImage as? UIImage
        else {
            homeVM.importImage = nil
            homeVM.didLoadNewImage = false
            return
        }
        var newDogImage = GalleryImage(context: viewContext)
        newDogImage.imageData = imageToAdd.pngData()
        newDogImage.date = Date()
        newDogImage.id = UUID()
    
        saveContext()
        homeVM.didLoadNewImage = false
    }
    private func deleteGalleryImage(uId: UUID?) {
        guard let uID = uId as? UUID else {
            return
        }
        withAnimation {
            for galleryImage in galleryImages {
            if galleryImage.id == uID {
                viewContext.delete(galleryImage)
                
            }
            }
            saveContext()
        }
    }
}

struct ImageIconView: View {
    
    var galleryImage : GalleryImage
    
    var body: some View {
        VStack {
            if (galleryImage.imageData == nil){
                Image(systemName: "photo.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding()
            } else {
                Image(uiImage:  UIImage(data: galleryImage.imageData!)! )
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding()
            }
            
            Text(galleryImage.name ?? "no name")
                .font(.caption)
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
