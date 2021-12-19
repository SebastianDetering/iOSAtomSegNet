//
//  ProcessingViewModel.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 12/17/21.
//

import Foundation
import CoreML
import SwiftUI

final class ProcessingViewModel: ObservableObject {
    
    @Published var imageInProcessing = false
    @Published var isLoadingActivations = false
    @Published var imageDidProcess = false
    @Published var cgImageOutput : CGImage?

    func processImage() {
        let serialQueue = DispatchQueue(label: "test.queue.Serial")
        imageDidProcess = false
        isLoadingActivations = true
        // This queue setup is how to make the spinner view update the way you want to.
        // The idea is to do view updates on the main thread, and image processing/model call on the background thread.
        serialQueue.async {
            if Thread.isMainThread {
                print("main Thread task")
            }
            else { print("Background thread task")}
            
        SegNetIOManager.shared.processImage() {
            result in
            DispatchQueue.main.async {
            self.isLoadingActivations = false
            switch result {
            case .success(let cgOut):
                self.imageDidProcess = true
                self.cgImageOutput = cgOut
            case .failure(let error):
                self.isLoadingActivations = false
                print(error.localizedDescription)
           }
            }
        
        }
        }
    }
}
