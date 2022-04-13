import Foundation
import SwiftUI



struct OutputsView: View {
        
        @StateObject var homeVM: HomeTabViewModel
        @StateObject var processingViewModel: ProcessingViewModel
        var parent: HomeTabView
        @State private var outputSelected = Set<OutputEntity>()

        @State var editMode = EditMode.inactive

        var body: some View {
                NavigationView {
                    List(selection: $outputSelected) {
                        ForEach(parent.outputEntities, id: \.self) { outputEntity in
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
                        
                    }   .navigationBarTitle( Text("Model Outputs"))
                        .navigationBarItems(leading: deleteButton, trailing: EditButton())
                    
                        .environment(\.editMode, self.$editMode)
                        .listStyle(.insetGrouped)
                        .background(LinearGradient(gradient: Gradient(colors: [processingViewModel.topGradientColor, processingViewModel.bottomGradientColor]), startPoint: .top, endPoint: .bottom))
                      //  .ignoresSafeArea() //the list goes into the top of screen, undesired
                } //end nav view
        }
    private var deleteButton: some View {
        if editMode == .inactive {
            return Button(action: {}) {
                Image(systemName: "")
            }
        } else {
            return Button(action: {deleteOutputEntities()}) {
                Image(systemName: "trash")
            }
        }
    }
    private func deleteOutputEntities() {
        var indices: [Int] = []
            for id in outputSelected {
                if let index = parent.outputEntities.lastIndex(where: { $0 == id })  {
                    indices.append(index)
               }
           }
        parent.deleteEntities(offsets: IndexSet(indices))
        outputSelected = Set<OutputEntity>()
    }
}
