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
                                                                        imageName: galleryImage.name ?? " No name ",
                                                                        id: galleryImage.id)
                                    processingViewModel.inspectingImage = true
                                }
                        }
                    }
                } .navigationBarHidden(galleryImages.count > 0)
                .navigationBarTitle("no sources")
            }
            .sheet(isPresented: $processingViewModel.inspectingImage) {
                ImageInspectView(homeVM: homeVM,
                                 processingVM: processingViewModel)
            }
            ImageActionsView(isImportViewShowing: $homeVM.showingImagePicker,
                             isPermissionsShowing: $homeVM.showingPermissionsSelector,
                             parent: self )
                .padding(.bottom, 10)
        }  .onChange(of: homeVM.importImage) {
            newImage in
            withAnimation {
            newGalleryImage()
            }
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
        var newGalleryImage = GalleryImage(context: viewContext)
        newGalleryImage.imageData = imageToAdd.pngData() // iphone camera roll images are jpeg, but this is working
        newGalleryImage.date = Date()
        newGalleryImage.id = UUID()
        if let newName = homeVM.importImageName {
            newGalleryImage.name  = newName
        }
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
    func getExampleAssets() {
        var galleryImageIds: [UUID]  = []
        for galleryImage in galleryImages {
            if let id = galleryImage.id {
            galleryImageIds.append(id)
            }
        }
        for exampleImage in exampleImages {
            if !(galleryImageIds.contains(exampleImage.id)) {
                guard let imageToAdd = UIImage(named: exampleImage.name) as? UIImage
                else {
                    homeVM.importImage = nil
                    homeVM.didLoadNewImage = false
                    return
                }
                var newGalleryImage = GalleryImage(context: viewContext)
                newGalleryImage.imageData = imageToAdd.pngData()
                newGalleryImage.date = exampleImage.date
                newGalleryImage.name  = exampleImage.name
                newGalleryImage.id = exampleImage.id
                saveContext()
                homeVM.didLoadNewImage = false
            }
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
    var parent: ImageGalleryView
    
    var body: some View{
        HStack {
            Button(action: {
                isImportViewShowing = true
                isPermissionsShowing = true
            },
                   label: {
                    Text("Camera Roll")
                    }
                   ) .padding(.trailing, 30)
            
            Button(action: {
                parent.getExampleAssets()
            }, label: {
                Text("example images")
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
