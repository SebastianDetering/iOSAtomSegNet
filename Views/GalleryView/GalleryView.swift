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
    @Binding var tabSelection: HomeTabs
    
    var body: some View {
        ZStack {
            
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: viewModel.columns) {
                        ForEach(exampleImages) { galleryImage in
                            
                            ImageView(imageName: galleryImage.name)
                                .padding(.bottom, 10)
                                .onTapGesture {
                                    processingViewModel.newSourceImage( sourceType: SourceTypes.Image, imageName: galleryImage.name)
                                }
                        }
                        ForEach( exampleSerFiles ) {
                            serFile in
                            FileView( serName: serFile.name)
                                .onTapGesture {
                                    processingViewModel.newSourceImage( sourceType: SourceTypes.Ser, imageName: serFile.name)
                                }
                        }
                    }
                }
                .navigationTitle("TEM Images")
            }
            .sheet(isPresented: $processingViewModel.imageInProcessing) {
                ImageInspectView(cgImageSource: $processingViewModel.sourceImage, imageDidLoad: $processingViewModel.sourceImageLoaded, isShowingView: $processingViewModel.imageInProcessing )
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

struct FileView: View {
    let serName: String
    var body: some View {
        VStack {
            Image(systemName: "doc")
                .resizable()
                .frame(width: 100, height: 100)
                .padding()
                .scaledToFit()
            Text(serName)
                .font(.caption)
        }
    }
}
