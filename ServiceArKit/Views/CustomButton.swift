//
//  CustomButton.swift
//  AdminServiceAR
//
//  Created by Александр Панин on 19.02.2023.
//

import SwiftUI

struct CustomButton: View {
    
    let text: String
    let color: Color
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void
    private var font: Font { iPad ? fontS : fontSm }
    var body: some View {
        Button {
            action()
        } label: {
            
            RoundedRectangle(cornerRadius: corner).foregroundColor(color.opacity(0.1)).frame(width: width, height: height)
                .background(RoundedRectangle(cornerRadius:  corner).stroke(color, lineWidth: 1))
                .overlay(
                    Text(text).font(font).foregroundColor(color).lineLimit(2).minimumScaleFactor(scale).padding(.all, sx)
                        .multilineTextAlignment(.center)
                )
        }
    }
}
