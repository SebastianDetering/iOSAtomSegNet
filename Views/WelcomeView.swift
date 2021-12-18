//
//  ContentView.swift
//  SwiftUISegNet
//
//  Created by sebi d on 9/12/21.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        TabView {
            GalleryView()
                .tabItem() {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("Gallery")
                }
                .tabItem() {
                    Image(systemName: "gearshape.2")
                    Text("Nueral Net")
                }
                .tabItem() {
                    Image(systemName: "paintbrush.pointed.fill")
                    Text("Touchup")
                }
        }
    }
}

