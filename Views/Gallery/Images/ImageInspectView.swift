//
//  ImageInspectView.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 12/27/21.
// see bottom for inspiration

import SwiftUI
import Foundation

struct ImageInspectView: View {
    
    @StateObject var homeVM: HomeTabViewModel
    @StateObject var processingVM: ProcessingViewModel
                
    var body: some View {
        VStack{
            GeometryReader { geometry in
                ZStack{
                    if processingVM.sourceImageLoaded {
                        ZoomableScrollView {
                            Image(uiImage: UIImage(cgImage: processingVM.sourceImage!))
                                // will be "contradictory" (ideal will exceed max for the oversized images), but that is why the max constraint is there.
                                .resizable()
                                .scaledToFit()
                                .frame(minWidth: 100,
                                       idealWidth:  (CGFloat(processingVM.sourceImage?.width ?? 200) / 1.5),
                                       maxWidth: 500,
                                       minHeight: 100,
                                       idealHeight:  (CGFloat(processingVM.sourceImage?.height ?? 200) / 1.5) ,
                                       maxHeight: 500,
                                       alignment: .center)
                            
                        }
                    }
                    else {
                        LoadingView()
                    }
                }.clipped()
        }
    
            HStack {
                
            Button(action: {
                moveToProcessingView()
            },
                       label:
                {
                     Text("process")
                    Image(systemName: "chevron.right")
                        
                       }
                )
            CloseButton(isShowingView: $processingVM.inspectingImage )
            } 
        }
    }
    private func moveToProcessingView() { // moving the source to processing, and some cleanup
        processingVM.inspectingImage = false
        processingVM.setWorkingImage()
        processingVM.clearOuputsImage()
        homeVM.selection = .NeuralNet
    }
}

//https://stackoverflow.com/questions/60637521/how-to-pinch-and-scroll-an-image-in-swiftui
