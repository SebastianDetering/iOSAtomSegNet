//
//  BackButton.swift
//  SwiftUISegNet
//
//  Created by sebi d on 9/20/21.
//

import SwiftUI

struct CloseButton: View {
    @Binding var isShowingView: Bool
    
    var body: some View {
        ZStack{
            Rectangle()
                .frame(width: 90, height: 30)
                .scaledToFill()
                .foregroundColor(.white)
                .cornerRadius(5)
            Text( "close" )
                .foregroundColor(.accentColor)
                .font(.system(size: 18, weight: .semibold, design: .default))
                    }
        .padding( 20)
        .padding(.leading, 10)

        .onTapGesture {
            isShowingView = false
        }
    }
}
