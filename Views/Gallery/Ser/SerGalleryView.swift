import SwiftUI

struct SerGalleryView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \SerEntity.date, ascending: false)])

    private var serEntities: FetchedResults<SerEntity>

    @StateObject var homeVM: HomeTabViewModel
    @StateObject var processingVM: ProcessingViewModel
    
    @State private var fileSelected = Set<UUID>()
    @State private var inspecting = false
    @State private var serName: String = ""
    @State private var serObject: SerEntity?
    
    var body: some View {
        NavigationView {
            List(selection: $fileSelected) {
              
                ForEach(serEntities) {
                    serEntity in
                    Text(serEntity.name ?? "Ser File Name Missing")
                        .onTapGesture {
                            serObject = serEntity
                            inspecting = true
                        }
                }
            } .sheet(isPresented: $inspecting) {
                SerInspectView(processingVM: processingVM, entityInspecting: $serObject, serFileName: $serName)
            }.onAppear(perform: {
                if !(homeVM.loadedPackagedSer) {
                    self.getExampleAssets() // attempted refactor, we'll see how this goes
                }
            })
            
        }
        SerActionsView( parent: self)
    }
    
    func getExampleAssets() {
        print("\(serEntities.count) ser Entities")
        var loadedIds: [UUID]  = []
        for entity in serEntities {
            if let id = entity.id {
            loadedIds.append(id)
            } else {
                print("WARNING serEntity id missing")
            }
        }
        print(loadedIds)
        for exampleSer in exampleSerFiles { // refactor for first time running using user defaults.
            if !(loadedIds.contains(exampleSer.id)) {
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
        homeVM.loadedPackagedSer = true
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

struct SerActionsView: View {

    var parent: SerGalleryView
    
    var body: some View{
        HStack {
            
            Button(action: {
                
                parent.getExampleAssets() // put in special settings (user can retrieve assets if deleted accidentally.)
            }, label: {
                Text("example ser files")
            })
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

