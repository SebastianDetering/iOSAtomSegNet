//
//  LoadingView.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 12/17/21.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.color = .brandSecondary
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        
    }
   
}

struct LoadingView: View {
    var body: some View {
        ActivityIndicator()
    }
}
