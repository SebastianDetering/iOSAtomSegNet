//
//  TouchupView.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 12/20/21.
//

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
                            HStack{
                                Image(systemName: "folder.fill")

                            Text( (outputEntity.name ?? "") + " \(outputEntity.date!)")
                            }
                        }
                    }
                } .navigationTitle("processing outputs")
            }
        }
}

//struct OutputView: View {
//    @Binding var outputEntity: OutputEntity
//
//    var body: some View {
//
//    }
//}
