import SwiftUI

struct SerGalleryView: View {
    
    @State private var fileSelected = Set<UUID>()
    @State private var inspecting = false
    @State private var serName: String = ""
    
   //@StateObject var serViewModel = SerViewModel()
    
    var body: some View {
        NavigationView {
            List(selection: $fileSelected) {
                ForEach(exampleSerFiles)  { fileName in
                    Text(fileName.name)
                    .onTapGesture {
                        serName = fileName.name
                        inspecting = true
            //            serViewModel.newSerSource(sourceName: $0.name)
                    }  }
            } .sheet(isPresented: $inspecting) {
                SerImportView(serFileName: $serName)
            }
        } 
    }
}


struct FileView: View {
    let serName: String
    var body: some View {
        VStack {
            Image(systemName: "doc")
                .resizable()
                .frame(width: 100, height: 100)
                .padding()
                .scaledToFit()
            Text(serName)
                .font(.caption)
        }
    }
}

