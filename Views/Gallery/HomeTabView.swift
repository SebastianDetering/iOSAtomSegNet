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
        guard let imageToAdd = processingViewModel.sourceImage else {
            processingViewModel.alertItem = AlertContext.noSourceImage
            return
        }
        guard let outputToAdd = processingViewModel.cgImageOutput
        else {
            processingViewModel.alertItem = AlertContext.noOutputs
            return
        }
        var newEntity = OutputEntity(context: viewContext)
        newEntity.sourceImage = UIImage(cgImage: imageToAdd).pngData()
        newEntity.outputImage = UIImage(cgImage: outputToAdd).pngData()
        newEntity.date = Date()
        newEntity.id = UUID()
        newEntity.name = processingViewModel.workingImageName
    
        saveContext()
       
    }
    func deleteEntities(offsets: IndexSet) {
        withAnimation {
            offsets.map { outputEntities[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }
}

