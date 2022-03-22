import SwiftUI

struct OutputEntityView: View {
    var outputEntity: OutputEntity
    @State var isOverlayed = false
    
    var body: some View {
        VStack {
        Text(outputEntity.name ?? "")
            if !isOverlayed {
        VStack {
            Text("source")
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
        } .animation(.easeInOut, value: isOverlayed)
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
                    }
                } .animation(.easeInOut, value: isOverlayed)
            }
            Button(action: { isOverlayed.toggle() },
               label: {
                Text("overlay")
               })
        }
        }
}
