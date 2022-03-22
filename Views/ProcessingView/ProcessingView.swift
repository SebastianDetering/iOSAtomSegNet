import SwiftUI

struct ProcessingView: View {
    
    @StateObject var homeVM: HomeTabViewModel
    @StateObject var processingVM : ProcessingViewModel
    @State var alertItem : AlertItem?
    @State var isShowingModelPicker: Bool = false
    var parent: HomeTabView
    
    var body: some View {
        ZStack{
            VStack {
                HStack{
                    if processingVM.workingImageName != nil {
                        Text("Image to Process: " + processingVM.workingImageName! )
                            .font(.system(size: 10, weight: .regular, design: .serif))
                            .foregroundColor(.brandSecondary)
                    }
                    else {
                        Text("please select a source image to process")
                            .font(.system(size: 10, weight: .regular, design: .serif))
                            .foregroundColor(.brandSecondary)
                    }
                }
                
                WorkingImageView(tabSelection: $homeVM.selection,
                                 workingImage: processingVM.workingImage,
                                 imageInProcessing: $processingVM.imageInProcessing)
                
                ModelOutputsView(imageDidProcess: $processingVM.imageDidProcess,
                                 cgImageOutput: $processingVM.cgImageOutput,
                                 isLoadingActivations: $processingVM.isLoadingActivations)
                ProcessStatusView(processStatus: $processingVM.processStatus)
                    .frame(width: 400, height: 10, alignment: .center)
                ProcessActionsView(processingVM: processingVM, homeTabViewParent: parent)
                ModelPickerView(currentModel: $processingVM.currentModel)
                
            }
            .frame(minWidth: 500, idealWidth: .greatestFiniteMagnitude, maxWidth: .greatestFiniteMagnitude, minHeight: 1800, idealHeight: .greatestFiniteMagnitude, maxHeight: .greatestFiniteMagnitude, alignment: .center)
            .scaledToFill()
            .background(LinearGradient(gradient: Gradient(colors: [processingVM.topGradientColor, processingVM.bottomGradientColor]), startPoint: .top, endPoint: .bottom))
        }
    }
}
