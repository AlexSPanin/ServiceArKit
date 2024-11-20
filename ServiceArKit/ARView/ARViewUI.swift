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
    private var widthButton: CGFloat { constants.view.width * (isUsingModel ? 0.3 : 0.78) }
    private var text: String {
        switch viewModel.statusAPP {
        case .configure: return "Конфигурация ARView"
        case .finishConfig: return "Загрузить Карточку"
        case .loadCard: return "Загрузка Карточки"
        case .createdModel, .finishCreatedModel : return "Подготовка Модели"
        case .loadModel, .finishLoadModel: return "Загрузка файлов Модели"
        case .searchScene, .checkScene: return "Поиск Плоскости"
        case .observerScene: return "Определите место"
        case .addModel: return "Установить"
        default: return "Конфигурация"
        }
    }
    private var isDisabled: Bool {
        switch viewModel.statusAPP {
        case .finishConfig, .finishCreatedModel, .observerScene: return false
        default: return true
        }
    }
    
    private var isUsingModel: Bool { viewModel.statusAPP == .useModel }
    
    private var button: (String, String) {
        switch viewModel.statusAPP {
        case .useModel: return ("На право", "Налево")
        default: return ("","")
        }
    }
    
    var body: some View {
        ZStack {
            ARViewContainer(viewModel: viewModel).edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center) {
                Spacer()
                if isUsingModel {
                    HStack {
                        Spacer()
                        CustomButton(text: button.1, color: mainLigth, background: mainRigth, width: widthButton) {
                            viewModel.movementModel = .rotateRigth
                        }
                        
                        Spacer()
                        
                        CustomButton(text: button.0, color: mainLigth, background: mainRigth, width: widthButton) {
                            viewModel.movementModel = .rotateLeft
                        }
                        Spacer()
                    }
                    .padding(.bottom, paddingBottom)
                    
                } else {
                    CustomButton(text: text, color: mainLigth, background: mainRigth, width: widthButton) {
                        switch viewModel.statusAPP {
                        case .finishConfig: viewModel.statusAPP = .loadCard
                        case .finishLoadModel: viewModel.statusAPP = .searchScene
                        case .observerScene: viewModel.statusAPP = .addModel
                        default: do {}
                        }
                    }
                    .padding(.bottom, paddingBottom)
                    .disabled(isDisabled ).opacity(isDisabled ? 0.4 : 1)
                }
            }
        }
        .ignoresSafeArea()
    }
}
