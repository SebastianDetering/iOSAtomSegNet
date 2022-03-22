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
                                    Text( (outputEntity.name ?? "") + "_\(outputEntity.modelUsed ?? "")")
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
