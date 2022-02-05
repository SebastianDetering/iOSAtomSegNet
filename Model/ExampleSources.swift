import SwiftUI


struct SerFile: Hashable, Identifiable {
    var id = UUID()
    
    var name: String
}

var exampleSerFiles: [SerFile] = [SerFile(name: "20.40.16 Scanning Acquire_0000_1"),
                                  SerFile(name: "20.40.16 Scanning Acquire_0000_2" )]
                                                                                                               
                                     
                                     
