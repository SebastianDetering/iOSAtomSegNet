import SwiftUI

enum HomeTabs: String {
    case Gallery = "images"
    case NeuralNet = "coreml"
    case Segment  = "outputs"
}

struct HomeTabView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \OutputEntity.date, ascending: false)])
    
    var outputEntities: FetchedResults<OutputEntity>
    
    @StateObject var processingViewModel: ProcessingViewModel
    @StateObject var homeViewModel: HomeTabViewModel
    
    var body: some View {
        TabView(selection: $homeViewModel.selection) {
            GalleryView(homeVM: homeViewModel,
                        processingViewModel: processingViewModel)
                .tabItem {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("Gallery")
                } .tag(HomeTabs.Gallery)
                .onDisappear(
                    perform: {
                        homeViewModel.previousSelection = HomeTabs.Gallery
                    } )
            ProcessingView(homeVM: homeViewModel,
                           processingVM: processingViewModel,
                           parent: self)
                .tabItem {
                    Image(systemName: "gearshape.2")
                    Text("Neural Net")
                } .tag(HomeTabs.NeuralNet)
                .onDisappear(
                    perform: {
                                homeViewModel.previousSelection = HomeTabs.NeuralNet
                } )
            OutputsView(homeVM: homeViewModel,
                        processingViewModel:  processingViewModel,
                        parent: self)
                .tabItem {
                    Image(systemName: "tray.full")
                    Text("Saved Outputs")
                } .tag(HomeTabs.Segment)
                .onDisappear(
                    perform: {
                        homeViewModel.previousSelection = HomeTabs.Segment
                    } )
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
    func newOutputEntity() {
        guard let imageToAdd = processingViewModel.sourceImage else { return }
        var newEntity = OutputEntity(context: viewContext)
        newEntity.sourceImage = UIImage(cgImage: imageToAdd).pngData()
        newEntity.date = Date()
        newEntity.id = UUID()
        newEntity.name = processingViewModel.workingImageName
    
        saveContext()
    }
    func deleteGalleryImage(uId: UUID?) {
        guard let uID = uId as? UUID else {
            return
        }
        withAnimation {
            for outputEntity in outputEntities {
                if outputEntity.id == uID {
                    viewContext.delete(outputEntity)
                }
            }
            saveContext()
        }
    }
}

