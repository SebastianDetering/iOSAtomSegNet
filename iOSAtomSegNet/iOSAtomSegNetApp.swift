//
//  iOSAtomSegNetApp.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 12/17/21.
//

import SwiftUI

@main
struct iOSAtomSegNetApp: App {

    @State var inputImage: UIImage?
    @StateObject var processingViewModel = ProcessingViewModel()
    @StateObject var homeViewModel = HomeTabViewModel()
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack{
                HomeTabView(processingViewModel: processingViewModel,
                            homeViewModel: homeViewModel)
                    .alert(item: $processingViewModel.alertItem) {
                        alertItem in
                        Alert(title: Text(alertItem.title), message: Text(alertItem.message), dismissButton: alertItem.dismissButton)
                    }
                if homeViewModel.hasRunPermissionSelector {
                    if homeViewModel.showingImagePicker {
                        ImagePicker(image: $inputImage, isShowing: $homeViewModel.showingImagePicker)
                    }
                } else {
                    if homeViewModel.showingPermissionsSelector{
                        PermissionsView(isShowing: $homeViewModel.showingPermissionsSelector,
                                        gotPermission: $homeViewModel.hasRunPermissionSelector)
                    }
                }
            }
        }
    }
}
