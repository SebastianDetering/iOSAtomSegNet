import SwiftUI

import SwiftUI

final class SerViewModel: ObservableObject {
    
    @Published var serName: String?
    @Published var serInspecting = false
    
    func newSerSource( sourceName: String) {
        serName = sourceName
        serInspecting = true
    }
}
