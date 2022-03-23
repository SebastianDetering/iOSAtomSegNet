import SwiftUI

struct SerImportView: View {

    @StateObject var importViewModel: SerImportViewModel
    
    var body: some View {
        VStack {
            GroupBox {
                HStack {
                    
                    Spacer()
                    
                    Button(action: { importViewModel.isImporting = true }, label: {
                        Text("Import")
                    })
                    
                    Spacer()
                    
                    Button(action: { importViewModel.isExporting = true }, label: {
                        Text("Export")
                    })
                    
                    Spacer()
                }
            }
        }
        .padding()
        .fileExporter(isPresented: $importViewModel.isExporting,
                      document: importViewModel.fileDocument,
            contentType: .data
        ) { result in
            if case .success = result {
                // Handle success.
            } else {
                // Handle failure.
            }
        }
        
        .fileImporter(
            isPresented: $importViewModel.isImporting,
            allowedContentTypes: [.data, .plainText],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFile: URL = try result.get().first else { return }
                let data = try Data(contentsOf: selectedFile)

                importViewModel.fileDocument?.binary = data
            } catch let error {
                // Handle failure.
                print("error getting file")
                print(error.localizedDescription)
            }
        }
    }
    
}
