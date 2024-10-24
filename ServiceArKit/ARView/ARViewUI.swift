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
    @StateObject var viewModel = ARViewModel()
    
    
    var body: some View {
        ZStack {
            ARViewContainer(viewModel: viewModel).edgesIgnoringSafeArea(.all)
        }
        .ignoresSafeArea()
        .onAppear {
            viewModel.configure()
        }
    }
}
