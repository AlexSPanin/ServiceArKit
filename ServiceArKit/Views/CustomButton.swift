//
//  CustomButton.swift
//  AdminServiceAR
//
//  Created by Александр Панин on 20.11.2024.
//

import SwiftUI

struct CustomButton: View {
    @EnvironmentObject var constants: ConstantSetting
    let text: String
    let color: Color
    let background: Color
    let width: CGFloat
    let action: () -> Void
    private var font: Font { constants.isSmall ? fontS : fontN }
    private var paddingTextButtonTop: CGFloat { constants.view.height * 0.016 }
    private var paddingTextButtonLeading: CGFloat { constants.view.width * 0.016 }
    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .font(font)
                .lineLimit(1)
                .minimumScaleFactor(scale)
                .foregroundColor(color)
                .padding(.vertical, paddingTextButtonTop)
                .padding(.horizontal, paddingTextButtonLeading)
                .frame(width: width)
                .background( background.cornerRadius(constants.corner))
        }
    }
}

