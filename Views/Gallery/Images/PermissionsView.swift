import SwiftUI

struct PermissionsView: UIViewControllerRepresentable {
    
    @Binding var isShowing: Bool
    @Binding var gotPermission: Bool
    
    func makeUIViewController(context: Context) -> PermissionsViewController {
        guard let permissionsVC = PermissionsViewController(showing: $isShowing, hasRun: $gotPermission) else { fatalError("Could not make the permissions view controller")}
        return permissionsVC
    }
    
    func updateUIViewController(_ uiViewController: PermissionsViewController, context: Context) {
        print("isSHowing \(isShowing)")
        if isShowing {
            
        } else {
            
        }
    }
        
}
