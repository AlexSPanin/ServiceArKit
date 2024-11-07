//
//  ExtensionsARView.swift
//  ServiceArKit
//
//  Created by Александр Панин on 04.10.2024.
//

import RealityKit

extension ARView {
    
    /// получаем anchor
    /// - Parameter compeation:  возвращает anchor
    func getAnchor(anchor: String, completion: @escaping(AnchorEntity?) -> Void) {
        completion(self.scene.anchors.first(where: {$0.name == anchor}) as? AnchorEntity)
    }
    
    /// получаем сцену по якорю
    /// - Parameter compeation: возвращает модель сцены
    func getScene(scene: String, anchor: String, completion: @escaping(ModelEntity?) -> Void) {
        getAnchor(anchor: anchor) { anchor in completion(anchor?.children.first (where: {$0.name == scene }) as? ModelEntity) }
    }
    
}

