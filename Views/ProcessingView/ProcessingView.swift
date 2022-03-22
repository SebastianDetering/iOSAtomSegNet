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
            }
            .frame(minWidth: 500, idealWidth: .greatestFiniteMagnitude, maxWidth: .greatestFiniteMagnitude, minHeight: 1800, idealHeight: .greatestFiniteMagnitude, maxHeight: .greatestFiniteMagnitude, alignment: .center)
            .scaledToFill()
            .background(LinearGradient(gradient: Gradient(colors: [processingVM.topGradientColor, processingVM.bottomGradientColor]), startPoint: .top, endPoint: .bottom))
        }
    }
}

    struct ProcessActionsView: View {

        @StateObject var processingVM: ProcessingViewModel
        var homeTabViewParent: HomeTabView
        
        var body: some View {
            VStack {
            HStack {
                Button(action:  { processSource()  },
                       label: { ProcessActionButton(text: "run inference", systemName: "gearshape.fill", relatedImage: $processingVM.sourceImage) })
                .padding(.trailing, 20)
                Button(action: { homeTabViewParent.newOutputEntity() },
                       label: { ProcessActionButton(text: "save", systemName: "tray.and.arrow.down", relatedImage: $processingVM.cgImageOutput) } )
            }
            
            ModelPickerView(currentModel: $processingVM.currentModel)
            }.alert(item: $processingVM.alertItem) {
                alertItem in
                Alert(title: Text(alertItem.title), message: Text(alertItem.message), dismissButton: alertItem.dismissButton)
            }
        }
        
        private func processSource() {
            do {
                try processingVM.processImage()
            } catch { switch error {
            case ModelIOErrors.MissingSourceImage:
                processingVM.alertItem = AlertContext.noSourceImage
            case ModelIOErrors.OversizedImageError:
                processingVM.alertItem = AlertContext.missizedImageInput
            case ModelIOErrors.PoorlyConfiguredMLMultiArrayInputShape:
                processingVM.alertItem = AlertContext.invalidImageInput
            default:
                print("add a default alert")
            }
            }
        }
    }



