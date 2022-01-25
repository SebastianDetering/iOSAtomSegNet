import SwiftUI

struct ContentView: View {
    
    @State private var document: MessageDocument = MessageDocument(message: "Hello, World!")
    @State private var isImporting: Bool = false
    @State private var isExporting: Bool = false
    
    var body: some View {
        VStack {
            GroupBox(label: Text("Message:")) {
                TextEditor(text: $document.message)
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
        
        .fileExporter(
            isPresented: $isExporting,
            document: document,
            contentType: .plainText,
            defaultFilename: "Message"
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
