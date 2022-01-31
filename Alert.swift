import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let dismissButton: Alert.Button
}

struct AlertContext {
    static let invalidImageInput = AlertItem(title: "Invalid Device input",
                                             message: "image was nil",
                                             dismissButton: .default(Text("OK")))
    static let missizedImageInput = AlertItem(title: "Invalid Device input",
                                              message: "image was too large",
                                              dismissButton: .default(Text("OK")))
    static let noSourceImage = AlertItem(title: "no source image",
                                                  message: "Please select a source image from the gallery.",
                                                  dismissButton: .default(Text("ok")))
}
