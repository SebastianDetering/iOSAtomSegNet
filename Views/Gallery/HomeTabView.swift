import SwiftUI

enum HomeTabs: String {
    case Gallery = "images"
    case NeuralNet = "coreml"
    case Segment  = "outputs"
}

struct HomeTabView: View {
    
    @StateObject var processingViewModel: ProcessingViewModel
    @StateObject var homeViewModel: HomeTabViewModel
    
    var body: some View {
        TabView(selection: $homeViewModel.selection) {
            GalleryView(homeVM: homeViewModel,
                        processingViewModel: processingViewModel)
                .tabItem {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("Gallery")
                } .tag(HomeTabs.Gallery)
                .onDisappear(
                    perform: {
                        homeViewModel.previousSelection = HomeTabs.Gallery
                    } )
            ProcessingView(homeVM: homeViewModel,
                           processingVM: processingViewModel)
                .tabItem {
                    Image(systemName: "gearshape.2")
                    Text("Neural Net")
                } .tag(HomeTabs.NeuralNet)
                .onDisappear(
                    perform: {
                                homeViewModel.previousSelection = HomeTabs.NeuralNet
                } )
            ExportView(viewModel: processingViewModel,
                       tabSelection: $homeViewModel.selection)
                .tabItem {
                    Image(systemName: "circle.dashed.inset.fill")
                    Text("Segment")
                } .tag(HomeTabs.Segment)
                .onDisappear(
                    perform: {
                        homeViewModel.previousSelection = HomeTabs.Segment
                    } )
        }
    }
}

