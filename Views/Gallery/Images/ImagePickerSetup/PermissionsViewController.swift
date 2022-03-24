import UIKit
import PhotosUI
import SwiftUI

class PermissionsViewController: UIViewController {

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
            showUI(for: PHPhotoLibrary.authorizationStatus())
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
    }
    func showLimitedAccessUI() {
        let photoCount = PHAsset.fetchAssets(with: nil).count
    }
    func gotoAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) else {
                assertionFailure("Not able to open App privacy settings")
                return
        }
        UIApplication.shared.open(url, options: [:])
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
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel )
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true )
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
        
        present(actionSheet, animated: true )
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
        
        present(alert, animated: true)
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

