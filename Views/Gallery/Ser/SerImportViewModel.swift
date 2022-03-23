import SwiftUI

final class SerImportViewModel: ObservableObject {
    
    @Published var serName: String?
    @Published  var isImporting: Bool = false
    @Published  var isExporting: Bool = false   // refactor all into a model
    @Published  var fileDocument: SerDocument?

    func newSerSource( sourceName: String) {
        serName = sourceName
    }
}
