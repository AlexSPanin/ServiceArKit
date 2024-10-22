//
//  ARViewContainer.swift
//  ServiceArKit
//
//  Created by Александр Панин on 22.10.2024.
//
import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var viewModel: ARViewModel
    func makeUIView(context: Context) -> some UIView {
        context.coordinator.view = viewModel.arView
        viewModel.arView.session.delegate = context.coordinator
        return viewModel.arView
    }
    func updateUIView(_ uiView: UIViewType, context: Context) { }
    func makeCoordinator() -> Coordinator { Coordinator() }
}

class Coordinator: NSObject, ARSessionDelegate {
    weak var view: ARView?

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
      // guard let view = self.view else { return }
      // debugPrint("Anchors added to the scene: ", anchors)
      // self.focusEntity = FocusEntity(on: view, style: .classic(color: .yellow))
    }
}
