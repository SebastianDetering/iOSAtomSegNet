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
    
    var body: some Scene {
        WindowGroup {
            WelcomeView(processingViewModel: processingViewModel)
        }
    }
}
