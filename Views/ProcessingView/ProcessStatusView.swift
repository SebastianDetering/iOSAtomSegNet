import SwiftUI

struct ProcessStatusView: View {
    
    @Binding var processStatus: ProcessingStatus
    var body: some View {
        switch processStatus {
        case .NoSource:
            Text("No Source")
                .foregroundColor(.secondary)
        case .ReadyToProcess:
            Text("Ready")
                .foregroundColor(.green)
        case .Oversized:
            Text("Oversized (512x512 recommended)")
                .foregroundColor(.gray)
        case .ProcessError:
            Text("Error")
                .foregroundColor(.red)
        case .ProcessCompleted:
            Text("Success! ready to save output")
                .foregroundColor(.green)
        case .Saved:
            Text("Success! saved output")
        case .Processing:
            Text("Processing...")
        }
    }
}
