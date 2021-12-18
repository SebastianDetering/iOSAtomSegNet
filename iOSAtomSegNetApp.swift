//
//  iOSAtomSegNetApp.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 12/17/21.
//

import SwiftUI

@main
struct iOSAtomSegNetApp: App {
    
    @StateObject var processingViewModel = ProcessingViewModel()
    
    var body: some Scene {
        WindowGroup {
            ImageProcessingView( viewModel: processingViewModel )
        }
    }
}
