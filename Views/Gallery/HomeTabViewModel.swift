import SwiftUI

final class HomeTabViewModel: ObservableObject {
    @AppStorage("currentTab") var selection: HomeTabs = .Gallery // selected tab same on relaunch
    
    @AppStorage("loadedExampleImages") var loadedPackagedImages = false
    @AppStorage("loadedExampleSer")    var loadedPackagedSer    = false
    
    @Published var previousSelection: HomeTabs = .Gallery
    
    @Published var showingPermissionsSelector = false

    @Published var showingImagePicker         = false
    @Published var showingLimitedSelector = false

    @Published var importImage: UIImage?
    @Published var importImageName: String?
    
    @Published var didLoadNewImage: Bool = false
    @Published var copyingAssets: Bool = false
}
