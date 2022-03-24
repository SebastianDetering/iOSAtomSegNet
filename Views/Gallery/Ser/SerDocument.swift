
import SwiftUI
import UniformTypeIdentifiers

struct SerDocument: FileDocument, Equatable {
    
    static var readableContentTypes: [UTType] { [.data] }

    var binary: Data
    
    init(rawData: Data) {
        self.binary = rawData
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        binary = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: binary)
    }
    
}
