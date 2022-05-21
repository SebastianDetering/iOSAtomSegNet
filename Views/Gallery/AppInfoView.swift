//
//  AppInfoView.swift
//  iOSAtomSegNet
//
//  Created by sebi d on 5/21/22.
//

import SwiftUI
extension Bundle {
    var iconFileName: String? {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconFileName = iconFiles.last
        else { return nil }
        return iconFileName
    }
}

struct AppIcon: View {
    var body: some View {
        Bundle.main.iconFileName
            .flatMap { UIImage(named: $0) }
            .map { Image(uiImage: $0) }
    }
}
struct AppInfoView: View {
    
    var body: some View {
        ScrollView {
            VStack {
                Text("About the App")
                    .font(.title)
                AppIcon()
                    .cornerRadius(7)
                Text("Atom Segmentation Network enables exploration of scientific electron microscope images for all.  The gallery is packaged with some example images the user may experiment with, as well as providing a reader for a propriety .ser electron microscope file format.")
                    .padding(.bottom, 5)
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                
                Image("tem-12")
                    .resizable()
                    .frame(maxWidth: 80, maxHeight: 80, alignment: .center)
                Text("We included atom resolution Transition Electron Microscope images, or TEM images.  Expensive electron microscopes acquire TEM images by firing a focused electron beam which scatters off of very small samples in order to achieve an image of atoms.  Unlike life-size photos, electron microscope photos at the atomic scale are imaging probabilities rather than classical structures because atoms are governed by quantum mechanics.  For this reason and because scattering adds randomness, atomic resolution images can be very noisy.")
                    .padding()
                HStack {
                    Image("tem2")
                    .resizable()
                    .frame(maxWidth: 80, maxHeight: 80, alignment: .center)
                    Image(systemName: "arrow.right")
                        .resizable()
                        .frame(maxWidth: 40, maxHeight: 40, alignment: .center)
                    Image("CoreMLLogo")
                    .resizable()
                    .frame(maxWidth: 80, maxHeight: 80, alignment: .center)
                    .cornerRadius(5)
                    Image(systemName: "arrow.right")
                        .resizable()
                        .frame(maxWidth: 40, maxHeight: 40, alignment: .center)
                    Image("tem2_Gaussian-Processed")
                        .resizable()
                        .frame(maxWidth: 80, maxHeight: 80, alignment: .center)
                }
                Text("The neural network included in our app addresses the issue of noisy images using Machine Learning, or ML.  The Deep EM Lab at UCI developed a neural network using the python ML application developer interface Pytorch – which can perform various denoising and deblurring of TEM images. We hope that the app increases your interest for the field of condensed matter and electron microscopy.")
                    .padding()
                Text("Credits")
                    .font(.title)
                Text("Developed for the DeepEMLab at University of California Irvine by Sebastian Detering")
                    .font(.headline)
                Link("TEMImageNet training library and AtomSegNet deep-learning models for high-precision atom segmentation, localization, denoising, and deblurring of atomic-resolution images", destination:  URL(string: "https://www.nature.com/articles/s41598-021-84499-w") ?? URL(string: "https://www.apple.com")!)
                    .padding(.bottom)
                
            }
        }
    }
}
