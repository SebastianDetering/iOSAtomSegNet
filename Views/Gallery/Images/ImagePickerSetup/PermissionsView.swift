import SwiftUI

struct PermissionsView: UIViewControllerRepresentable {
    
    @Binding var isShowing: Bool
    
    func makeUIViewController(context: Context) -> PermissionsViewController {
        return PermissionsViewController()
    }
    
    func updateUIViewController(_ uiViewController: PermissionsViewController, context: Context) {
        print("isSHowing \(isShowing)")
    }
        
}
