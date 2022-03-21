import SwiftUI

struct SerInspectView: View {
    
    @StateObject var processingVM: ProcessingViewModel
    
    @Binding var entityInspecting: SerEntity?
    @State private var _serHeader: SerHeader = SerHeader()
    @State private var _serHeaderDescription: SerHeaderDescription = SerHeaderDescription()
    
    @Binding var serFileName: String
    
    var body: some View {
        VStack {
            Button( "Parse \(serFileName).ser",
                   action:      {
                    do {
                        if entityInspecting != nil {
                        SegNetIOManager.InitializeSer(serObject: entityInspecting!) {
                            result in
                                print("Ser File initialized successfully")
                        }
                        _serHeader = SegNetIOManager.getHeader()
                        _serHeaderDescription = SegNetIOManager.getHeaderDescription()
                            SegNetIOManager.LoadSerImage() {
                                result in
//                                processingVM.newSourceImage(sourceType: .SerFile,
//                                                            image: result.pixelData(),
//                                                            imageName: <#T##String#>,
//                                                            id: <#T##UUID?#>)
                            }
                        }
                    }
                    catch { print("\(error)")} }
                   )
                   
            GroupBox {
                VStack {
                    SerDescriptionView(headerDescription: $_serHeaderDescription)
                    SerDetailView(serHeader: $_serHeader)
               
                }
            }
        }
    }
    
}
