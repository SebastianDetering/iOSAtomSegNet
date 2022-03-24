import SwiftUI

struct SerInspectView: View {
    
    var parent: SerGalleryView
    @StateObject var processingVM: ProcessingViewModel
    
    @Binding var entityInspecting: SerEntity?
    @State private var _serHeader: SerHeader = SerHeader()
    @State private var _serHeaderDescription: SerHeaderDescription = SerHeaderDescription()
    @State private var _errorDescription: String?

    @Binding var serFileName: String
        
    var body: some View {
        VStack {
            GroupBox {
                VStack {
                    
                    if _errorDescription != nil {
                    Text(_errorDescription!)
                            .foregroundColor(.red)
                    }
                    SerDescriptionView(headerDescription: $_serHeaderDescription)
                    //SerDetailView(serHeader: $_serHeader) not useful for humans
                    SerImageDataView(serEntity: $entityInspecting,
                                     loading: $processingVM.loadingSourceImage,
                                     sourceImage: $processingVM.sourceImage)
                    CloseButton(isShowingView: $processingVM.inspectingImage )
                }
            }
        } .onAppear {
                _errorDescription = nil
            do {
                if entityInspecting != nil {
                SegNetIOManager.InitializeSer(serObject: entityInspecting!) {
                    result in
                        print("Ser File initialized successfully")
                }
                    if let fetchedHeader = SegNetIOManager.getHeader() {
                        _serHeader = fetchedHeader
                        _serHeaderDescription = SegNetIOManager.getHeaderDescription()
                    }
                    if entityInspecting?.imageData == nil { // write to ser Entity's image data the cgImage data
                        processingVM.newSourceImage(sourceType: .SerFile,
                                                    image: nil,
                                                    imageName: entityInspecting?.name ?? "name nil!",
                                                    id: entityInspecting?.id,
                                                    serEntity: $entityInspecting)
                    }
                } else {
                    _errorDescription = "Ser file was nil"
                }
        }
    }
    }
}

struct SerImageDataView: View {
    
    @Binding var serEntity: SerEntity?
    @Binding var loading: Bool
    @Binding var sourceImage: CGImage?
    
    var body: some View {
        if serEntity?.imageData == nil {
            if  loading {
                LoadingView()
                    .frame(width: 100, height: 100, alignment: .top)
            } else {
                Image(systemName: "square.slash")
                    .resizable()
                    .frame(width: 100, height: 100, alignment: .top)
            }
        } else {
            ZoomableScrollView {
                Image(uiImage: UIImage(data: serEntity!.imageData!) ?? UIImage())
                    // will be "contradictory" (ideal will exceed max for the oversized images), but that is why the max constraint is there.
                    .resizable()
                    .scaledToFit()
                    .frame(minWidth: 100,
                           idealWidth:  (CGFloat(sourceImage?.width ?? 200) / 1.5),
                           maxWidth: 500,
                           minHeight: 100,
                           idealHeight:  (CGFloat(sourceImage?.height ?? 200) / 1.5) ,
                           maxHeight: 500,
                           alignment: .top)
            }
        }
    }
}
