import SwiftUI

struct SourceImageView: View {
    @Binding var tabSelection: HomeTabs
    var sourceImage: CGImage?
    @Binding var imageInProcessing: Bool
    
    var body: some View {
        if sourceImage != nil {
            Image( uiImage: UIImage(cgImage: sourceImage!) ) // should have viewModel.workingImage passed in
                .resizable()
                .frame(width: 230, height: 230)
        } else {
            ZStack{
                Rectangle()
                    .frame(width: 230, height: 230, alignment: .center)
                    .foregroundColor(.brandPrimary)
                Button(action: { imageInProcessing = false; tabSelection = .Gallery}, label: {Text("select image to process")} )
                    .frame(width: 230, height: 230, alignment: .center)
                    .foregroundColor(.accentColor)
            }
        }
    }
}
