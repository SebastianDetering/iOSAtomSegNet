import SwiftUI

struct ProcessingView: View {
    
    @StateObject var homeVM: HomeTabViewModel
    @StateObject var processingVM : ProcessingViewModel
    @State var alertItem : AlertItem?
    @State var isShowingModelPicker: Bool = false
    
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
                        Text("no source image")
                            .font(.system(size: 10, weight: .regular, design: .serif))
                            .foregroundColor(.brandSecondary)
                    }
                        
                    BackButton(text: "back",
                               isShowingView: $processingVM.imageInProcessing,
                               previousView: $homeVM.previousSelection,
                               currentView: $homeVM.selection)
                }
                
                WorkingImageView(tabSelection: $homeVM.selection,
                                workingImage: processingVM.workingImage,
                                imageInProcessing: $processingVM.imageInProcessing)
                
                ModelOutputsView(imageDidProcess: $processingVM.imageDidProcess,
                                 cgImageOutput: $processingVM.cgImageOutput,
                                    isLoadingActivations: $processingVM.isLoadingActivations)
                
                Button(action:   {do {
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
                }} },
                label: { RunInferenceButtonLabel() })
                
                HStack{
                    Text("current model")
                        .padding(.leading, 10)
                        .foregroundColor(.primary)
                    Spacer()
                    ModelPickerView(currentModel: $processingVM.currentModel)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 10)
                }.frame(width: 400, height: 60, alignment: .trailing)
                .background(Color(.systemBackground))
                .cornerRadius(4)
            }.alert(item: $processingVM.alertItem) {
                alertItem in
                Alert(title: Text(alertItem.title), message: Text(alertItem.message), dismissButton: alertItem.dismissButton)
            }
        }
        .frame(minWidth: 500, idealWidth: .greatestFiniteMagnitude, maxWidth: .greatestFiniteMagnitude, minHeight: 1800, idealHeight: .greatestFiniteMagnitude, maxHeight: .greatestFiniteMagnitude, alignment: .center)
        .scaledToFill()
        .background(LinearGradient(gradient: Gradient(colors: [.brandPrimary, Color(.secondarySystemBackground)]), startPoint: .top, endPoint: .bottom))
    }
    
    
}





