//
//  GalleryView.swift
//  SwiftUISegNet
//
//  Created by sebi d on 9/12/21.
//

import SwiftUI


struct GalleryView: View {
    
    @StateObject var viewModel = GalleryViewModel()
    @StateObject var processingViewModel: ProcessingViewModel
    
    var body: some View {
        ZStack {
            
            NavigationView {
        ScrollView {
            LazyVGrid(columns: viewModel.columns) {
                ForEach(exampleImages) { galleryImage in
                    ImageView(imageName: galleryImage.name)
                        .padding(.bottom, 30)
                        .onTapGesture {
                            print("in process")
                            processingViewModel.imageInProcessing = true
                            SegNetIOManager.shared.setWorkingImage( galleryImage )
                        }
                }
            }
        }
        .navigationTitle("Image Gallery")
            }
            .sheet(isPresented: $processingViewModel.imageInProcessing) {
           
                ProcessingView(viewModel: processingViewModel )
            
            }
        }
        
    }
}

struct ImageView: View {
    let imageName: String
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .frame(width: 100, height: 100)
                .padding()
            Text(imageName)
                .font(.caption)
        }
    }
}
