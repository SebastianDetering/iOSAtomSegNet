//
//  ImageProcessingView.swift
//  SwiftUISegNet
//
//  Created by sebi d on 9/13/21.
//

import SwiftUI
import CoreML

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let dismissButton: Alert.Button
}

struct AlertContext {
    static let invalidImageInput = AlertItem(title: "Invalid Device input", message: "image was nil", dismissButton: .default(Text("OK")))
    
    static let missizedImageInput = AlertItem(title: "Invalid Device input", message: "image was too large", dismissButton: .default(Text("OK")))
    
}

struct ProcessingView: View {
    
    @StateObject var viewModel : ProcessingViewModel
    @State var alertItem : AlertItem?
    @Binding var tabSelection: HomeTabs
    @Binding var previousTabSelection: HomeTabs
    @State var isShowingModelPicker: Bool = false
    
    var body: some View {
        ZStack{
            VStack {
                HStack{
                    Text("Image to Process: " + (viewModel.newWorkingImageName ?? "") )
                        .font(.system(size: 10, weight: .regular, design: .serif))
                        .foregroundColor(.brandSecondary)
                    BackButton(text: "back",
                               isShowingView: $viewModel.imageInProcessing,
                               previousView: $previousTabSelection,
                               currentView: $tabSelection)
                }
                
                ImageSourceView(tabSelection: $tabSelection,
                                sourceImage: $viewModel.sourceImage,
                                imageInProcessing: $viewModel.imageInProcessing)
                
                ModelOutputsView(imageDidProcess: $viewModel.imageDidProcess,
                                 cgImageOutput: $viewModel.cgImageOutput,
                                 isLoadingActivations: $viewModel.isLoadingActivations)
                
                Button(action:   {do {
                    try viewModel.processImage()
                } catch { print(error.localizedDescription)} },
                label: { RunInferenceButtonLabel() })
                
                HStack{
                    Text("current model")
                        .padding(.leading, 10)
                        .foregroundColor(.primary)
                    Spacer()
                    ModelPickerView(currentModel: $viewModel.currentModel)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 10)
                }.frame(width: 400, height: 60, alignment: .trailing)
                .background(Color(.systemBackground))
                .cornerRadius(4)
                
            }
        }
        .frame(minWidth: 500, idealWidth: .greatestFiniteMagnitude, maxWidth: .greatestFiniteMagnitude, minHeight: 1800, idealHeight: .greatestFiniteMagnitude, maxHeight: .greatestFiniteMagnitude, alignment: .center)
        .scaledToFill()
        .background(LinearGradient(gradient: Gradient(colors: [.brandPrimary, Color(.secondarySystemBackground)]), startPoint: .top, endPoint: .bottom))
    }
    
    
}





