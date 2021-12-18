//
//  ImageProcessingView.swift
//  SwiftUISegNet
//
//  Created by sebi d on 9/13/21.
//

import SwiftUI
import CoreML

struct ImageProcessingView: View {
    
    @StateObject var viewModel : ProcessingViewModel
    
    var body: some View {
        
            VStack {
                
                HStack(alignment: .top){
                    Spacer()
                    BackButton(text: "back to gallery", isShowingView: $viewModel.imageInProcessing)
                }
                .padding(.bottom, 4)
                Text("Image to Process: \(viewModel.workingImage.name)")
                    .font(.system(size: 10, weight: .regular, design: .serif))
                    .foregroundColor(.brandSecondary)
                
                Image(viewModel.workingImage.name)
                    .resizable()
                    .frame(width: 230, height: 230)
                if viewModel.imageDidProcess {
                    Image.init(uiImage: UIImage(cgImage: viewModel.cgImageOutput!))
                    .resizable()
                    .frame(width: 230, height: 230)
                } else {
                    ZStack{
                        
                    Image(systemName: "rectangle.fill")
                        .resizable()
                        .frame(width: 230, height: 230)
                        .accentColor(.brandSecondary)
                        
                        if viewModel.loadingActivations {
                            LoadingView()
                        }
                    }
                    
                }
                Button() {
                    viewModel.processImage()
                } label: {
                    HStack {
                        Text("run inference")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.accentColor)
                        Image(systemName: "gearshape.2.fill")
                            .foregroundColor(.accentColor)
                    }
                    .padding(4)
                    .background(Color(.label))
                    //.cornerRadius(6)
                }
                
//                Picker("Model", selection: $currentModel, content: { // <2>
//                    Text(MLModels.guassianMask.rawValue).tag(MLModels.guassianMask) // <3>
//                    Text(MLModels.circularMask.rawValue).tag(MLModels.circularMask) // <4>
//                    Text(MLModels.denoise.rawValue).tag(MLModels.denoise) // <5>
//                })
            
            } .background(LinearGradient(gradient: Gradient(colors: [.brandPrimary, Color(.secondarySystemBackground)]), startPoint: .top, endPoint: .bottom))
    }
}



