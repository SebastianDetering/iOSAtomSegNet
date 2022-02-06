import SwiftUI


struct SerFile: Hashable, Identifiable {
    var id = UUID()
    
    var name: String
}

struct ExampleImage: Hashable, Identifiable {
    var id = UUID()
    
    var name: String
    var uiimage: UIImage?
}

var exampleSerFiles: [SerFile] = [SerFile(name: "20.40.16 Scanning Acquire_0000_1"),
                                  SerFile(name: "20.40.16 Scanning Acquire_0000_2" )]
                                                                                                               
                                     
var exampleImages: [ExampleImage] = [ExampleImage(name: "tem2"),
                                     ExampleImage(name:"12219"),
                                     ExampleImage(name:"03_afterimage_8nm_crp"),
                                     ExampleImage(name: "12219_Rect")]

