import SwiftUI


struct ProcessActionsView: View {

    @StateObject var processingVM: ProcessingViewModel
    var homeTabViewParent: HomeTabView
    
    var body: some View {
            HStack {
                Button(action:  { if processingVM.sourceImage != nil { processSource() } },
                       label: { ProcessActionButton(text: "run inference",
                                                    systemName: "gearshape.fill",
                                                    relatedImage: $processingVM.sourceImage)
                })
                .padding(.trailing, 20)
                Button(action: { if processingVM.cgImageOutput != nil { homeTabViewParent.newOutputEntity() } },
                       label: { ProcessActionButton(text: "save",
                                                    systemName: "tray.and.arrow.down",
                                                    relatedImage: $processingVM.cgImageOutput)
                } )
            }
        .alert(item: $processingVM.alertItem) {
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



