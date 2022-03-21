import SwiftUI

struct SerGalleryView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \SerEntity.date, ascending: false)])

    private var galleryImages: FetchedResults<SerEntity>

    @StateObject var homeVM: HomeTabViewModel
    @State private var fileSelected = Set<UUID>()
    @State private var inspecting = false
    @State private var serName: String = ""
        
    var body: some View {
        NavigationView {
            List(selection: $fileSelected) {
                ForEach(exampleSerFiles)  { fileName in
                    Text(fileName.name)
                    .onTapGesture {
                        serName = fileName.name
                        inspecting = true
            //            serViewModel.newSerSource(sourceName: $0.name)
                    }  }
            } .sheet(isPresented: $inspecting) {
                SerImportView(serFileName: $serName)
            }
        } 
    }
    
    func getExampleAssets() {
        homeVM.loadedPackagedAssets = true
        var serFileIds: [UUID]  = []
        for serFile in exampleSerFiles {
            serFileIds.append(serFile.id)
        }
        for exampleSer in exampleSerFiles { // refactor for first time running using user defaults.
            if !(serFileIds.contains(exampleSer.id)) {
                guard let serDataToAdd = NSDataAsset(name: exampleSer.name)
                else {
                    fatalError("Error loading bundled ser file from asset catalogue:: \(exampleSer.name)")
                    return
                }
                var newSer = SerEntity(context: viewContext)
                newSer.serBinary = serDataToAdd.data
                newSer.date = exampleSer.date
                newSer.name  = exampleSer.name
                newSer.id = exampleSer.id
                saveContext()
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
}


struct FileView: View {
    let serName: String
    var body: some View {
        VStack {
            Image(systemName: "doc")
                .resizable()
                .frame(width: 100, height: 100)
                .padding()
                .scaledToFit()
            Text(serName)
                .font(.caption)
        }
    }
}

