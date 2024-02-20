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
                .environment(\.managedObjectContext,
                              persistenceController.container.viewContext)
                // add another alert for importing, exporting as part of Home View Model, or refactor processingViewModel
                .alert(item: $processingViewModel.alertItem) {
                    alertItem in
                    Alert(title: Text(alertItem.title), message: Text(alertItem.message), dismissButton: alertItem.dismissButton)
                }
                
                .sheet(isPresented: $homeViewModel.showingImagePicker) {
                    ImagePicker(imageName: $homeViewModel.importImageName,
                                image: $homeViewModel.importImage,
                                isShowing: $homeViewModel.showingImagePicker,
                                hasImported: $homeViewModel.didLoadNewImage,
                                importStatus: $homeViewModel.importStatus)
                }
                
                .JMModal(showModal: $homeViewModel.showingPermissionsSelector, for: [.photo], autoDismiss: true, autoCheckAuthorization: false, restrictDismissal: false)
                .changeHeaderTo("App Permissions")
                .changeHeaderDescriptionTo("Export and Import of images requires photos access.")
                .changeBottomDescriptionTo("Atom Segmentation Network includes Powerful machine learning processing tools you can use to process electron microscope images in standard formats: png, jpeg... Atom Seg Net stores imported images and does not share any of the users photos outside the app. By allowing the app to import photos, you can process your own images. If you do not authorize Atom Seg Net for photo access, you must use settings to change authorization.  \n Atom Segmentation Network is more interesting when your own electron microscope images are imported for processing. Atom Segmentation does not sell, share, track or record your data, it runs locally.")
                //.setPermissionComponent(for: .photo, title: "allow photo access")
            }.onAppear {
                MLModelLibrary.fillLibrary()
                // I added these to have the background appear in the output view too
                UINavigationBar.appearance().backgroundColor = UIColor(processingViewModel.topGradientColor)
                UITableView.appearance().backgroundColor = .clear
            }
        }
    }
}
