//
//  BackButton.swift
//  SwiftUISegNet
//
//  Created by sebi d on 9/20/21.
//

import SwiftUI

struct BackButton: View {
    var text: String
    @Binding var isShowingView: Bool
    var body: some View {
        ZStack{
            ZStack(alignment: .leading) {
            Rectangle()
                .frame(width: 200, height: 30)
                .scaledToFill()
                .foregroundColor(.white)
                .cornerRadius(5)
                 
                Image(systemName: "chevron.backward")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.leading, 5)
            }
            Text(text)
                .foregroundColor(.accentColor)
                .font(.system(size: 18, weight: .semibold, design: .default))
                    }
        .padding( 20)
        .onTapGesture {
                        isShowingView = false
                    }
    }
}

struct Button_Previews: PreviewProvider {
    static var previews: some View {
        BackButton(text: "back", isShowingView: .constant(false))
    }
}
