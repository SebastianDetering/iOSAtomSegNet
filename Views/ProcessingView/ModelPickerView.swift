import SwiftUI

struct ModelPickerView: View {
    
    @Binding var currentModel: MLModels
    
        var body: some View {
            HStack {
            Text("model")
                .foregroundColor(.primary)
                .font(.caption)
                Spacer()
                Picker( selection: $currentModel, label:  Image(systemName: "chevron.up")){
                    ForEach(MLModels.allCases, id: \.self) {
                        Text( $0.rawValue ).tag( $0 )
                    }
                } .pickerStyle(.segmented)
                Spacer()
            }.frame(width: 400, height: 60, alignment: .center)
                .background(Color(.systemBackground))
                .cornerRadius(4)
        }
}



