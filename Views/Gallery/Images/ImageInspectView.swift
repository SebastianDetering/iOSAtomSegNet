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
        
    @State var crosshairShowing: Bool = false
        
    var body: some View {
        VStack{
            GeometryReader { geometry in
                ZStack{
                    if processingVM.sourceImageLoaded {
                        ZoomableScrollView<Image> {
                            Image(uiImage: UIImage(cgImage: processingVM.sourceImage!))
                        }
                    }
                    else {
                        LoadingView()
                    }
                    if crosshairShowing {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.red)
                    }
                }.clipped()
            // will be "contradictory" (ideal will exceed max for the oversized images), but that is why the max constraint is there.
            .frame(minWidth: 100,
                   idealWidth:  (CGFloat(processingVM.sourceImage?.width ?? 200) / 1.5),
                   maxWidth: 500,
                   minHeight: 100,
                   idealHeight:  (CGFloat(processingVM.sourceImage?.height ?? 200) / 1.5) ,
                   maxHeight: 500,
                   alignment: .center)
        }
    
            HStack {
            Button(action:
                    {crosshairShowing = !crosshairShowing},
                   label:
                    {
                        Text("crosshair")}
                    )
            Button(action: {
                moveToProcessingView()
            },
                       label:
                {
                     Text("process")
                    Image(systemName: "chevron.right")
                        
                       }
                )
            BackButton(text: "close",
                       isShowingView: $processingVM.inspectingImage,
                       previousView: .constant(HomeTabs.Gallery),
                       currentView: .constant(HomeTabs.Gallery) )
            }
        }
    }
    private func moveToProcessingView() { // moving the source to processing, and some cleanup
            processingVM.setWorkingImage()
            processingVM.clearOuputsImage()
            homeVM.selection = .NeuralNet
            processingVM.inspectingImage = false
    }
}

//https://stackoverflow.com/questions/60637521/how-to-pinch-and-scroll-an-image-in-swiftui
