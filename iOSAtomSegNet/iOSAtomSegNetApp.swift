//
//  iOSAtomSegNetApp.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 12/17/21.
//

import SwiftUI

@main
struct iOSAtomSegNetApp: App {
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    let persistenceController = PersistenceController.shared
    @StateObject var processingViewModel = ProcessingViewModel()
    @StateObject var homeViewModel = HomeTabViewModel()
    var body: some Scene {
        WindowGroup {
//            ZStack{
//            Rectangle()
//                Button(action: { showingImagePicker = true }, label: { Text("importImage") })
//            } .sheet(isPresented: $showingImagePicker, content: { Imag})
            HomeTabView(processingViewModel: processingViewModel, homeViewModel: homeViewModel   )
                .alert(item: $processingViewModel.alertItem) {
                    alertItem in
                    Alert(title: Text(alertItem.title), message: Text(alertItem.message), dismissButton: alertItem.dismissButton)
                }        }
            
    }
}
