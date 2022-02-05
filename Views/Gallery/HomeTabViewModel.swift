import SwiftUI

final class HomeTabViewModel: ObservableObject {
    @Published var selection: HomeTabs = .Gallery
    @Published var previousSelection: HomeTabs = .Gallery
    
    @Published var showingPermissionsSelector = false
    @Published var hasRunPermissionSelector = false // only the modification can run after the first launch of the app.
    @Published var showingImagePicker         = false

    @Published var importImage: UIImage?
    
}
