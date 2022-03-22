
import SwiftUI

struct OutputActionsView: View {
    
    @Binding var isOverlayed: Bool
    @Binding var isSharing: Bool
    
    var body: some View {
        HStack {
            Button(action: { isSharing.toggle() },
                   label:  { ShareButton() })
            Spacer()
            Button(action: { isOverlayed.toggle() },
                   label: {
                Text("overlay")
            })
        }
    }
}
