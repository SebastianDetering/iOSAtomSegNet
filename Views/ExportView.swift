//
//  TouchupView.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 12/20/21.
//

import Foundation
import SwiftUI

struct ExportView: View {
    
    @StateObject var viewModel : ProcessingViewModel
    @Binding var tabSelection: HomeTabs
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.newWorkingImageName != nil {
                HStack(alignment: .center){
                    Text("Image to Process: " + viewModel.newWorkingImageName! )
                        .foregroundColor(.brandSecondary)
                    Image(uiImage: UIImage(cgImage: SegNetIOManager.getWorkingImage()!))
                        .resizable()
                        .frame(width: 75, height: 75)
                    Spacer()
                    
                } .padding(.top, 20)
                .padding(.bottom, 25)
                
                } else { Spacer()
                    Text("source image missing, select one from the gallery")}
                
                
                ZStack{
                    if viewModel.imageDidProcess {
                        Image.init(uiImage: UIImage(cgImage: viewModel.cgImageOutput!))
                            .resizable()
                            .frame(width: 230, height: 230)
                    } else {
                        Rectangle()
                            .frame(width: 230, height: 230, alignment: .center)
                            .foregroundColor(.brandPrimary)
                        Text("Model output will appear when Neural Net->run inference is pressed.")
                            .frame(width: 230, height: 230, alignment: .center)
                    }
                    if viewModel.isLoadingActivations {
                        LoadingView()
                    }
                }
               
                Spacer()
            } .background(LinearGradient(gradient: Gradient(colors: [.brandPrimary, Color(.secondarySystemBackground)]), startPoint: .top, endPoint: .bottom))
            .ignoresSafeArea()
        }
    }
}
