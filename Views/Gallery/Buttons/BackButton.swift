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
    @Binding var previousView: HomeTabs
    @Binding var currentView: HomeTabs
    
    var body: some View {
        ZStack{
            Rectangle()
                .frame(width: 90, height: 30)
                .scaledToFill()
                .foregroundColor(.white)
                .cornerRadius(5)
            Text( text )
                .foregroundColor(.accentColor)
                .font(.system(size: 18, weight: .semibold, design: .default))
                    }
        .padding( 20)
        .padding(.leading, 10)

        .onTapGesture {
                        let temp = currentView
                        currentView = previousView
                        previousView = temp
                        isShowingView = false
                    }
    }
}

struct Button_Previews: PreviewProvider {
    static var previews: some View {
        BackButton(text: "back", isShowingView:  .constant(false), previousView: .constant(HomeTabs.Gallery), currentView: .constant(HomeTabs.NeuralNet))
    }
}
