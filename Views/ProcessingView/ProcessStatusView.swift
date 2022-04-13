import SwiftUI

struct ProcessStatusView: View {
    
    @Binding var processStatus: ProcessingStatus
    var body: some View {
        switch processStatus {
        case .NoSource:
            ProcessLabelView(text: "no source",
                             color: .gray)
        case .ReadyToProcess:
            ProcessLabelView(text: "Ready",
                             color: .green)
        case .Oversized:
            ProcessLabelView(text: "Oversized (512x512 recommended)",
                             color: .gray)
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
        case .AlreadyProcessing:
            Text("Wait until finished!")
                .foregroundColor(.orange)
        }
        
    }
}

struct ProcessLabelView: View {
    
    var text: String
    var color: Color
    var body: some View {
        Text(text)
            .foregroundColor(color)
            .frame(width: 300, height: 40, alignment: .center)
                .background(Color(.systemBackground))
                .cornerRadius(4)
                .padding(5)
    }
}
