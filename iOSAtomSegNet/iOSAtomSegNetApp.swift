//
//  iOSAtomSegNetApp.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 12/17/21.
//

import SwiftUI

@main
struct iOSAtomSegNetApp: App {
    
    @StateObject var processingViewModel = ProcessingViewModel() // the idea is so that current model is saved across the app, and even the current output is cached, leaving the processing view shouldnt delete all the info in the processing view.
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
//            ZStack{
//            Rectangle()
//                Button(action: { showingImagePicker = true }, label: { Text("importImage") })
//            } .sheet(isPresented: $showingImagePicker, content: { Imag})
            HomeTabView(processingViewModel: processingViewModel   )
        }
    }
}
