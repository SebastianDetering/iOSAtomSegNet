import SwiftUI

struct ImageImportStatusView: View {
    
    @Binding var importStatus: ImportStatuses
    @Binding var importedName: String?
    var entityNumber: Int
    
    var body: some View {
        switch importStatus {
        case .NoImport:
            Text("\(entityNumber) images available")
        case .Success:
            Text("successfully imported \(importedName ?? "?")") // at some point refactor to delay the .NoImpo
                .foregroundColor(.green)
        case .Denied:
            Text("you don't have access to this photo, allow in settings")
                .foregroundColor(.red)
        }
    }
}
