import SwiftUI

struct PermissionsView: UIViewControllerRepresentable {
    
    @Binding var isShowing: Bool
    
    func makeUIViewController(context: Context) -> PermissionsViewController {
        guard let permissionsVC = PermissionsViewController(showing: $isShowing) else { fatalError("Could not make the permissions view controller")}
        return permissionsVC
    }
    
    func updateUIViewController(_ uiViewController: PermissionsViewController, context: Context) {
        print("isSHowing \(isShowing)")
    }
        
}
