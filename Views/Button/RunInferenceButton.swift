
import SwiftUI

struct RunInferenceButtonLabel: View {
    
    @Binding var sourceImage: CGImage?
    
    var body: some View {
    
           
        if sourceImage == nil {
            HStack {
                Text("run inference")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.gray)
                Image(systemName: "gearshape.2.fill")
                    .foregroundColor(.gray)
            }
            .padding(4)
            .background(Color(.label))
            .cornerRadius(2)
        } else {
            HStack {
                Text("run inference")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.accentColor)
                Image(systemName: "gearshape.2.fill")
                    .foregroundColor(.accentColor)
            }
            .padding(4)
            .background(Color(.label))
            .cornerRadius(2)
        }
        
    }
}

