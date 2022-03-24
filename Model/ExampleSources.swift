import SwiftUI


struct SerFile: Hashable, Identifiable {
    var id: UUID
    
    var name: String
    var date: Date
}

struct ExampleImage: Hashable, Identifiable {
    var id: UUID
    
    var name: String
    var date: Date
    var uiimage: UIImage?
}

var exampleSerFiles: [SerFile] = [SerFile(id: UUID(uuidString: "276E29B6-AF73-4992-B4FB-65A8CA6E3659")!,
                                          name: "20.40.16 Scanning Acquire_0000_1",
                                          date: Date(timeIntervalSince1970: 1644111302.434362)),
                                  SerFile(id: UUID(uuidString: "CEAE6C3B-25AA-4196-B3DE-E526D6F83CFE")!,
                                          name: "20.40.16 Scanning Acquire_0000_2",
                                          date: Date(timeIntervalSince1970: 1644111302.434362)),
//                                  SerFile(id: UUID(uuidString: "C8ACB5C8-D2E5-4A80-B787-2032DFCD6452")!,
//                                          name: "20.40.16 Scanning Acquire_0000",
//                                          date: Date(timeIntervalSince1970: 1644111302.434362))  // this was .emi
]

                                     
var exampleImages: [ExampleImage] = [ExampleImage(id: UUID(uuidString: "777F5628-A6FA-4DCF-B3D8-0F03863DBDD7")!,
                                                  name: "tem2",
                                                  date: Date(timeIntervalSince1970: 1644111302.434362)),
//                                     ExampleImage(id: UUID(uuidString: "C18E24C0-B344-449A-A39D-6FA8110AD544")!,
//                                                  name: "tem-12",
//                                                  date: Date(timeIntervalSince1970: 1644111302.434362)), // Mar 24 tem-12 has a bug, zeros on the pixel data when input to model somehow which is very strange
                                     ExampleImage(id: UUID(uuidString: "98BC0215-6EE1-4D17-9AA9-571BE2E975C6")!,
                                                  name:"12219",
                                                  date: Date(timeIntervalSince1970: 1644111302.434362)),
                                     ExampleImage(id: UUID(uuidString: "6DC41009-8EF5-4409-8775-A89ADBE2C6B8")!,
                                                  name:"03_afterimage_8nm_crp",
                                                  date: Date(timeIntervalSince1970: 1644111302.434362))
                                     ]

