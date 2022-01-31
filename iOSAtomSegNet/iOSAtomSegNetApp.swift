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
