//
//  Extensions.swift
//  ServiceArKit
//
//  Created by Александр Панин on 04.10.2024.
//
import RealityKit

/// Печать сообщения для отладки
/// - Parameters:
///   - message: сообщение
///   - isPrint: локальный признак разрешения печати
func printMessage(_ message: String?, isPrint: Bool = true ) {
    guard isPrinting, isPrint, let message = message else { return }
    print(message)
}

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
