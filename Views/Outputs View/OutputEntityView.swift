import SwiftUI
import UIKit

struct OutputEntityView: View {
    var outputEntity: OutputEntity
    @State var isOverlayed = false
    @State private var isSharing = false
    
    var body: some View {
        VStack {
            
        Text(outputEntity.name ?? "")
            if !isOverlayed {
        VStack {
            if outputEntity.sourceImage != nil {
              
                ZoomableScrollView  {
                Image(uiImage: UIImage(data: outputEntity.sourceImage!)!)
                    .resizable()
                    .frame(width:250, height: 250)
                
                }
                }
             else {
                Image(systemName: "square.slash")
                    .frame(width:100, height: 100)
            }
      
            Text("output")
            if outputEntity.outputImage != nil {
                ZoomableScrollView {
                Image(uiImage: UIImage(data: outputEntity.outputImage!)!)
                    .resizable()
                    .frame(width:250, height: 250)
                }
            } else {
                Image(systemName: "square.slash")
                    .frame(width: 100, height: 100)
            }
        }
            }
            else {
                ZStack {
                    
                    ZoomableScrollView {
                        ZStack {
                    if outputEntity.sourceImage != nil {
                      
                        Image(uiImage: UIImage(data: outputEntity.sourceImage!)!)
                            .resizable()
                            .frame(width:250, height: 250)
                            
                        }
                        
                     else {
                        Image(systemName: "square.slash")
                            .frame(width:100, height: 100)
                    }
                    if outputEntity.outputImage != nil {
                            Image(uiImage: UIImage(data: outputEntity.outputImage!)!)
                            .resizable()
                            .frame(width:250, height: 250)
                                .contrast(3.0)
                                
                                .colorMultiply(.red)
                                .opacity(0.3)
                    } else {
                        Image(systemName: "square.slash")
                            .frame(width: 100, height: 100)
                    }
                        }
                    }.animation(.easeInOut, value: isOverlayed)
                }
            }
            OutputActionsView(isOverlayed: $isOverlayed, isSharing: $isSharing)
               
            Spacer()
        } .sheet(isPresented: $isSharing, content: {
            ActivityView(activityItems: [outputEntity.outputImage!, outputEntity.sourceImage!])
        })
        }
 
}
