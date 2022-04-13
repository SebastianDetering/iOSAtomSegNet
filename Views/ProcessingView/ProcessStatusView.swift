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
            ProcessLabelView(text: "Error",
                             color: .red)
        case .ProcessCompleted:
            ProcessLabelView(text: "Success! ready to save output",
                             color: .green)
        case .Saved:
            ProcessLabelView(text: "Success! saved output")
        case .Processing:
            ProcessLabelView(text: "Processing...")
        case .AlreadyProcessing:
            ProcessLabelView(text: "Wait until finished!",
                             color: .orange)
        }
        
    }
}

struct ProcessLabelView: View {
    
    var text: String
    var color: Color = .primary
    var body: some View {
        Text(text)
            .foregroundColor(color)
            .frame(width: 300, height: 40, alignment: .center)
                .background(Color(.systemBackground))
                .cornerRadius(4)
                .padding(5)
    }
}
