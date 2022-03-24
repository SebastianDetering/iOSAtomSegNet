import SwiftUI

struct ShareButton: View {
    var body: some View {
        Image(systemName: "square.and.arrow.up")
            .resizable()
            .frame(width: 50, height: 50,alignment: .center)
            .scaledToFit()
    }
}

struct SerShareButton: View {
    
    @Binding var serEntity: SerEntity?
    
    var body: some View {
        Image(systemName: "square.and.arrow.up")
            .resizable()
            .frame(width: 50, height: 50,alignment: .center)
            .scaledToFit()
            .foregroundColor( (serEntity?.imageData == nil) ? .gray : .accentColor)
    }
}
