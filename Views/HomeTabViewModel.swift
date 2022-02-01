import SwiftUI

final class HomeTabViewModel: ObservableObject {
    @Published var selection: HomeTabs = .Gallery
    @Published var previousSelection: HomeTabs = .Gallery
    
    
}
