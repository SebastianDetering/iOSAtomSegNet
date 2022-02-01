import SwiftUI

struct SerImportView: View {
    //    @State private var _serHeader: SerHeader?
//    @State private var _serReader: FileSer?
  // @State private var rawData: Data!
    @State private var fileDocument: SerDocument!
    @State private var _serHeader: SerHeader = SerHeader()
    @State private var _serHeaderDescription: SerHeaderDescription = SerHeaderDescription()
    @State private var isImporting: Bool = false
    @State private var isExporting: Bool = false   // refactor all into a model
    
    @Binding var serFileName: String
    var cachedImage: CGImage?
    
    var body: some View {
        VStack {
            Button( "Parse \(serFileName).ser",
                   action:      {
                    do {
                        SegNetIOManager.InitializeSerInfo() {
                            result in
                                print("Got a CGOutput from this image.")
                            
                        }
                        fileDocument = SerDocument(rawData:  SegNetIOManager.getBinary())
                        _serHeader = SegNetIOManager.getHeader()
                        _serHeaderDescription = SegNetIOManager.getHeaderDescription()
                    }
                    catch { print("\(error)")} }
                   )
                   
            GroupBox {
                VStack {
                    SerDescriptionView(headerDescription: $_serHeaderDescription)
                   // SerDetailView(serHeader: $_serHeader)
                HStack {
                    
                    Spacer()
                    
                    Button(action: { isImporting = true }, label: {
                        Text("Import")
                    })
                    
                    Spacer()
                    
                    Button(action: { isExporting = true }, label: {
                        Text("Export")
                    })
                    
                    Spacer()
                }
                }
            }
        }
        .padding()
        .fileExporter(isPresented: $isExporting,
            document: fileDocument,
            contentType: .data
        ) { result in
            if case .success = result {
                // Handle success.
            } else {
                // Handle failure.
            }
        }
        
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.plainText],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFile: URL = try result.get().first else { return }
                let data = try Data(contentsOf: selectedFile)

                fileDocument.binary = data
            } catch {
                // Handle failure.
            }
        }
    }
    
}
