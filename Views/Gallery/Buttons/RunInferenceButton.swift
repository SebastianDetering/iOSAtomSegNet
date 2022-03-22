
import SwiftUI

struct ProcessActionButton: View {
    
    var text: String
    var systemName: String
    @Binding var relatedImage: CGImage?
    
    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor( (relatedImage == nil) ? .gray : .accentColor)
            Image(systemName: systemName)
                .foregroundColor(.gray)
        }
        .padding(4)
        .background(Color(.label))
        .cornerRadius(2)
    }
}

