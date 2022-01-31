//
//  HomeTabView.swift
//  SwiftUISegNet
//
//  Created by sebi d on 9/12/21.
//

import SwiftUI

enum HomeTabs: String {
    case Gallery = "images"
    case NeuralNet = "coreml"
    case Segment  = "outputs"
}

struct HomeTabView: View {
    
    @StateObject var processingViewModel: ProcessingViewModel
    @State var selection: HomeTabs = .Gallery
    @State var previousSelection: HomeTabs = .Gallery
    
    var body: some View {
        TabView(selection: $selection) {
            GalleryView(processingViewModel: processingViewModel, tabSelection: $selection)
                .tabItem {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("Gallery")
                } .tag(HomeTabs.Gallery)
                .onDisappear(perform: { previousSelection = HomeTabs.Gallery; print("\(previousSelection)")} )

            ProcessingView(viewModel: processingViewModel, tabSelection: $selection, previousTabSelection: $previousSelection)
                .tabItem {
                    Image(systemName: "gearshape.2")
                    Text("Neural Net")
                } .tag(HomeTabs.NeuralNet)
                .onDisappear(perform: { previousSelection = HomeTabs.NeuralNet; print("\(previousSelection)")} )
            ExportView(viewModel: processingViewModel,  tabSelection: $selection)
                .tabItem {
                    Image(systemName: "circle.dashed.inset.fill")
                    Text("Segment")
                } .tag(HomeTabs.Segment)
                .onDisappear(perform: { previousSelection = HomeTabs.Segment; print("\(previousSelection)")} )

                .tabItem {
                    Image(systemName: "paintbrush.pointed.fill")
                    Text("Touchup")
                }
                .tabItem {
                    Image(systemName: "paintbrush.pointed.fill")
                    Text("Centroids")
                }
        }
    }
}

