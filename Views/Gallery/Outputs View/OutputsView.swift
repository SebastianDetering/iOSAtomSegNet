import Foundation
import SwiftUI

struct OutputsView: View {
        
        @StateObject var homeVM: HomeTabViewModel
        @StateObject var processingViewModel: ProcessingViewModel
        var parent: HomeTabView
    
        @State private var outputSelected = Set<UUID>()

        var body: some View {
            VStack {
                NavigationView {
                    List(selection: $outputSelected) {
                        ForEach(parent.outputEntities) { outputEntity in
                            NavigationLink(
                                destination: OutputEntityView(outputEntity: outputEntity)) {
                                HStack{
                                    Image(systemName: "folder.fill")
                                    Text( (outputEntity.name ?? "") + " \(outputEntity.date!)")
                                }
                            }
                        }.onDelete(perform: { indexSet in
                            parent.deleteEntities(offsets: indexSet)
                        })
                    }.navigationBarTitle("saved outputs")
                }
            }
        }
}

struct OutputEntityView: View {
    var outputEntity: OutputEntity

    var body: some View {
        VStack {
        Text(outputEntity.name ?? "")
        VStack {
            Text("source")
            if outputEntity.sourceImage != nil {
                Image(uiImage: UIImage(data: outputEntity.sourceImage!)!)
                    .resizable()
            } else {
                Image(systemName: "square.slash")
                    .frame(width:100, height: 100)
            }
            Text("output")
            if outputEntity.outputImage != nil {
                Image(uiImage: UIImage(data: outputEntity.outputImage!)!)
                    .resizable()
            } else {
                Image(systemName: "square.slash")
                    .frame(width: 100, height: 100)
            }
        } .frame(width: 300, height: 600)
            
        }
    }
}
