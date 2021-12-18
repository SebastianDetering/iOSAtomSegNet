//
//  GalleryImages.swift
//  SwiftUISegNet
//
//  Created by sebi d on 9/20/21.
//

import SwiftUI


struct GalleryImage: Hashable,  Identifiable {
    var id = UUID()
    
    var name: String
}

let exampleImages: [GalleryImage] = [GalleryImage(name:"tem-12"),
                                     GalleryImage(name:"12219"),
                                     GalleryImage(name:"03_afterimage_8nm_crp"),
                                     GalleryImage(name:"12219"),
                                     GalleryImage(name:"12219"),
                                     GalleryImage(name:"tem-12"),
                                     GalleryImage(name:"tem-12"),
                                     GalleryImage(name:"tem-12")]
