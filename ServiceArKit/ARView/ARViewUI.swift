//
//  ARViewUI.swift
//  ServiceArKit
//
//  Created by Александр Панин on 23.10.2024.
//

import SwiftUI
import RealityKit

struct ARViewUI: View {
    @EnvironmentObject var activ: AppState
    @EnvironmentObject var constants: ConstantSetting
    
    @StateObject var viewModel = ARViewModel()
    
    private var font: Font { constants.isSmall ? fontS : fontN }
    private var paddingBottom: CGFloat { constants.view.height * 0.154 }
    private var paddingTextButtonTop: CGFloat { constants.view.height * 0.016 }
    private var paddingTextButtonLeading: CGFloat { constants.view.width * 0.016 }
    private var widthButton: CGFloat { constants.view.width * 0.78 }
    
    
    var body: some View {
        ZStack {
            ARViewContainer(viewModel: viewModel).edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center) {
                Spacer()
                Button {
                    viewModel.createdModel()
                } label: {
                    Text(viewModel.isLoad ? "Загрузка" : "Установить Модель")
                        .font(font)
                        .lineLimit(1)
                        .minimumScaleFactor(scale)
                        .foregroundColor(mainLigth)
                        .padding(.vertical, paddingTextButtonTop)
                        .padding(.horizontal, paddingTextButtonLeading)
                        .frame(width: widthButton)
                        .background( mainRigth.cornerRadius(constants.corner))
                }
                .padding(.bottom, paddingBottom)
                .disabled(viewModel.isLoad).opacity(viewModel.isLoad ? 0.3 : 1)
                
            }
        }
        .ignoresSafeArea()
        .onAppear {
            viewModel.constant = constants
            viewModel.configure()
        }
        
    }
}
