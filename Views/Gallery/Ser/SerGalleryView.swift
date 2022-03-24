import SwiftUI
import PermissionsSwiftUIPhoto

struct SerGalleryView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \SerEntity.date, ascending: false)])

    private var serEntities: FetchedResults<SerEntity>

    @StateObject var homeVM: HomeTabViewModel
    @StateObject var processingVM: ProcessingViewModel
    
    @State  var isImporting: Bool = false
    @State private var fileSelected = Set<UUID>()
    @State private var serName: String = ""
    @State private var serObject: SerEntity?
    @State var fileDocument: SerDocument? = nil  // refactoring into View Model Broke this setup
    
    var body: some View {
        VStack {
        NavigationView {
            List(selection: $fileSelected) {
                ForEach(serEntities) {
                    serEntity in
                    HStack {
                        if serEntity.imageData != nil {
                            Image(uiImage: UIImage(data: serEntity.imageData!) ?? UIImage())
                                .resizable()
                                .frame(width: 50, height: 50, alignment: .leading)
                        } else {
                            Image(systemName: "gyroscope")
                                .resizable()
                                .frame(width: 50, height: 50, alignment: .leading)
                        }
                        Text(serEntity.name ?? "Ser File Name Missing")
                    }
                        .onTapGesture {
                            serObject = serEntity
                            processingVM.inspectingImage = true
                        }
                }
            } .sheet(isPresented: $processingVM.inspectingImage) {
                SerInspectView(parent: self,
                               processingVM: processingVM,
                               entityInspecting: $serObject,
                               serFileName: $serName)
            }.onAppear(perform: {
                if !(homeVM.loadedPackagedSer) {
                    self.getExampleAssets() // attempted refactor, we'll see how this goes
                }
            })
            
        }
        SerActionsView( parent: self)
        } .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.data, .plainText],
            allowsMultipleSelection: false
        ) { result in
            do {
                    guard let selectedFile: URL = try result.get().first else { return }
                    if selectedFile.startAccessingSecurityScopedResource() {
                        let data = try Data(contentsOf: selectedFile)
                        defer { selectedFile.stopAccessingSecurityScopedResource()}
                        fileDocument = SerDocument(rawData: data)
                    } else {
                        print("No permission for this url")
                        throw "problem, denied by startAccessingSecurityScopedResource"
                    }
            } catch let error {
                // Handle failure.
                print("error getting file")
                print(error.localizedDescription)
            }
        }
            .onChange(of: fileDocument) {
            newSer in
            newSerEntity()
        }
    }
    func newSerEntity() { // refactor to test if this will be a valid
        guard let serToAdd = fileDocument?.binary else { return }
        var newSer = SerEntity(context: viewContext)
        newSer.serBinary = serToAdd
        newSer.date = Date()
        newSer.id = UUID()
        newSer.name  =  fileDocument.debugDescription
        saveContext()
        homeVM.didLoadNewImage = false
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
    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved Error: \(error)")
        }
    }
    
    func importSerFile() {
        isImporting.toggle()
    }
}

struct SerActionsView: View {

    var parent: SerGalleryView
    
    var body: some View{
        HStack {
            Button(action: {
                parent.importSerFile()
            },
                   label: {
                Text("import ser files")
            })
            
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

