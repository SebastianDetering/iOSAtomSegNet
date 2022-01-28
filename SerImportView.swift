import SwiftUI

struct SerImportView: View {
    
    @State private var _serFile: SerFile = SerFile(name: "20.40.16 Scanning Acquire_0000_1")
    @State private var _serHeader: SerHeader
    @State private var _serReader: FileSer?
    @State private var rawData: Data
    @State private var isImporting: Bool = false
    @State private var isExporting: Bool = false
    
    var body: some View {
        VStack {
            Button("read Ser File")
                .onTapGesture {
                    _serReader = try FileSer.init(filename: _serFile.name)
                }
            GroupBox {
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
        .padding()
        
        .fileExporter(isPresented: $isExporting,
            document: rawData,
            contentType: .data,
            defaultFilename: "mySerFile"
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
                guard let message = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }

                document.message = message
            } catch {
                // Handle failure.
            }
        }
    }
    
}
