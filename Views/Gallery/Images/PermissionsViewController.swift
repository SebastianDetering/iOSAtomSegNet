import UIKit
import PhotosUI
import SwiftUI

class PermissionsViewController: UIViewController {
    
    var isShowing: Binding<Bool>
    var gotPermission: Binding<Bool>
    
    init?(showing: Binding<Bool>, hasRun: Binding<Bool>) {
        gotPermission = hasRun
        isShowing = showing
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Request permission to access photo library
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] (status) in
            DispatchQueue.main.async { [unowned self] in
                showUI(for: status)
            }
        }
        }
        else {
            gotPermission.wrappedValue = true
        }
    }
// this is just for handling permissions, the actual fetching of images can be done by the picker
    func showUI(for status: PHAuthorizationStatus) {
        switch status {
        case .authorized:
            showFullAccessUI()

        case .limited:
            showLimitedAccessUI()

        case .restricted:
            showRestrictedAccessUI()

        case .denied:
            showAccessDeniedUI()

        case .notDetermined:
            break

        @unknown default:
            break
        }
    }
    func showRestrictedAccessUI() {
    }
    // Both these fetch Assets can only run once, I dont know why, maybe because you can only set preferences once at runtime.
    func showFullAccessUI() {
        let pCount = PHAsset.fetchAssets(with: nil).count // count of all the users photos
        isShowing.wrappedValue = false
    }
    func showLimitedAccessUI() {
        let photoCount = PHAsset.fetchAssets(with: nil).count
        isShowing.wrappedValue = false
    }
    func gotoAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) else {
                assertionFailure("Not able to open App privacy settings")
                return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: { _ in self.isShowing.wrappedValue = false })
    }
    func showAccessDeniedUI() {
        let actionSheet = UIAlertController(title: "",
                                            message: "Access to Photos denied, go to Settings to allow access to all photos.",
                                            preferredStyle: .actionSheet)
        let allowFullAccessAction = UIAlertAction(title: "Go to Privacy Settings",
                                                  style: .default) { [unowned self] (_) in
            // Open app privacy settings
            gotoAppPrivacySettings()
        }
        actionSheet.addAction(allowFullAccessAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in self.isShowing.wrappedValue = false } )
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: { self.isShowing.wrappedValue = false } )
    }
    func modifyPermissions() {
        let actionSheet = UIAlertController(title: "",
                                            message: "Select more photos or go to Settings to allow access to all photos.",
                                            preferredStyle: .actionSheet)
        
        let selectPhotosAction = UIAlertAction(title: "Select more photos",
                                               style: .default) { [unowned self] (_) in
            // Show limited library picker
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
        }
        actionSheet.addAction(selectPhotosAction)
        
        let allowFullAccessAction = UIAlertAction(title: "Allow access to all photos",
                                                  style: .default) { [unowned self] (_) in
            // Open app privacy settings
            gotoAppPrivacySettings()
        }
        actionSheet.addAction(allowFullAccessAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil )
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: { self.isShowing.wrappedValue = false } )
    }
    func seeAll(){
        let alert = UIAlertController(title: "Allow access to your photos",
                                      message: "This lets you share from your camera roll and enables other features for photos and videos. Go to your settings and tap \"Photos\".",
                                      preferredStyle: .alert)
        
        let notNowAction = UIAlertAction(title: "Not Now",
                                         style: .cancel,
                                         handler: nil )
        alert.addAction(notNowAction)
        
        let openSettingsAction = UIAlertAction(title: "Open Settings",
                                               style: .default) { [unowned self] (_) in
            // Open app privacy settings
            gotoAppPrivacySettings()
        }
        alert.addAction(openSettingsAction)
        
        present(alert, animated: true, completion: { self.isShowing.wrappedValue = false })
    }
}

extension PermissionsViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async { [unowned self] in
            // Obtain authorization status and update UI accordingly
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            showUI(for: status)
        }
    }
}

