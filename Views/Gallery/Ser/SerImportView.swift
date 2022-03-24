import SwiftUI

struct SerImportView: View {

    @StateObject var importViewModel: SerImportViewModel
    @State var fileDocument: SerDocument
    
    var body: some View {
        VStack {
            Text("Placeholder")
        }
        .padding()
        .fileExporter(isPresented: $importViewModel.isExporting,
                      document: fileDocument,
            contentType: .data
        ) { result in
            if case .success = result {
                // Handle success.
            } else {
                // Handle failure.
            }
        }
        
       
    }
    
}
