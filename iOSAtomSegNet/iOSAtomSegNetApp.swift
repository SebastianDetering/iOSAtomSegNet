import SwiftUI

@main
struct iOSAtomSegNetApp: App {

    @StateObject var processingViewModel = ProcessingViewModel()
    @StateObject var homeViewModel = HomeTabViewModel()
    // this way of doing it doesnt show the image picker right after permissions selector finished running
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack{
                HomeTabView(processingViewModel: processingViewModel,
                            homeViewModel: homeViewModel)
                    // add another alert for importing, exporting as part of Home View Model, or refactor processingViewModel
                    .alert(item: $processingViewModel.alertItem) {
                        alertItem in
                        Alert(title: Text(alertItem.title), message: Text(alertItem.message), dismissButton: alertItem.dismissButton)
                    }
                    .environment(\.managedObjectContext,
                                 persistenceController.container.viewContext)
                    .sheet(isPresented: $homeViewModel.showingImagePicker) {
                        ImagePicker(imageName: $homeViewModel.importImageName,
                                                image: $homeViewModel.importImage,
                                                isShowing: $homeViewModel.showingImagePicker,
                                                hasImported: $homeViewModel.didLoadNewImage
                                               )
                         }
                
                if homeViewModel.showingPermissionsSelector {
                        PermissionsView(isShowing: $homeViewModel.showingPermissionsSelector,
                                        gotPermission: $homeViewModel.hasRunPermissionSelector)
                    }
                
            }
        }
    }
}
