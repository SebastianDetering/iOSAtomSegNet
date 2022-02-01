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
    
    @State var currentScale: CGFloat = 1.0
    @State var previousScale: CGFloat = 1.0
    
    @State var currentOffset = CGSize.zero
    @State var previousOffset = CGSize.zero
    
    let horizBound: CGFloat = 300
    let vertBound:   CGFloat = 300
    let maxZoom: CGFloat = 10
    let minZoom: CGFloat = 1
        
    var body: some View {
        VStack{
            GeometryReader { geometry in
                ZStack{
                    if processingVM.sourceImageLoaded {
                        Image(uiImage: UIImage(cgImage: processingVM.sourceImage! ))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .offset(x: self.currentOffset.width, y: self.currentOffset.height)
                            .scaleEffect(max(self.currentScale,1.0))
                            .gesture(DragGesture()
                                        .onChanged { value in
                                            let deltaX = value.translation.width - self.previousOffset.width
                                            let deltaY = value.translation.height - self.previousOffset.height
                                            self.previousOffset.width = value.translation.width
                                            self.previousOffset.height = value.translation.height
                                            //bounding movement
                                            let newOffsetWidth = self.currentOffset.width + deltaX
                                            if newOffsetWidth <= geometry.size.width - horizBound && newOffsetWidth > horizBound - geometry.size.width {
                                                self.currentOffset.width = self.currentOffset.width + deltaX / self.currentScale
                                            }
                                            let newOffsetHeight = self.currentOffset.height + deltaY
                                            if newOffsetHeight <= geometry.size.height - vertBound  && newOffsetHeight > vertBound - geometry.size.height {
                                                self.currentOffset.height = self.currentOffset.height + deltaY / self.currentScale
                                            }
                                        }
                                        .onEnded { value in self.previousOffset = CGSize.zero })
                            
                            .gesture(MagnificationGesture()
                                        .onChanged { value in
                                            let delta = value / self.previousScale
                                            self.previousScale = value
                                            self.currentScale = self.currentScale * delta
                                        }
                                        .onEnded { _ in
                                            self.previousScale = 1.0
                                            if currentScale < 1.0 {
                                                self.currentScale = 1.0
                                            }
                                        })
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
    
            Text( String(format: "center: %.1f, %.1f",
                         arguments: [currentOffset.height, currentOffset.width ] ) )
            HStack {
            Button(action:
                    {crosshairShowing = !crosshairShowing},
                   label:
                    {
                        Text("crosshair")}
                    )
            Button(action: {
                processingVM.setWorkingImage()
                homeVM.selection = .NeuralNet
                processingVM.inspectingImage = false
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
}

//https://stackoverflow.com/questions/60637521/how-to-pinch-and-scroll-an-image-in-swiftui
