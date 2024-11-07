//
//  CreatedModelManager.swift
//  ServiceArKit
//
//  Created by Александр Панин on 26.10.2024.
//

import SwiftUI
import RealityKit

class CreatedModelManager {
    
    static let shared = CreatedModelManager()
    private init()  {}
    
    /// Формирование модели точки прицеливания
    /// - Parameters:
    ///   - name: системное имя модели точки прицеливания
    ///   - size: размер
    ///   - color: цвет
    ///   - nameStick: наименование модели указки
    /// - Returns: модель точки прицеливания
    func getPointForEntity(_ name: String, size: Float, color: UIColor, nameStick: String? = nil) -> ModelEntity {
        
        var mesh = MeshResource.generatePlane(width: size, depth: size, cornerRadius: 1)
        var material = SimpleMaterial(color: color, isMetallic: false)
        let point = ModelEntity(mesh: mesh, materials: [material])
        point.name = name
        
        guard let nameStick = nameStick else { return point }
        var stick = ModelEntity()
        do {
            let maskot = try ModelEntity.load(named: nameStick)
            stick.addChild(maskot)
            stick.name = "stick"
            stick.scale *= 0.05
        } catch {
            mesh = MeshResource.generateBox(width: size / 10, height: size * 4, depth: size / 10, cornerRadius: 1)
            material = SimpleMaterial(color: .red, isMetallic: false)
            stick = ModelEntity(mesh: mesh, materials: [material])
            stick.name = "stick"
            stick.position.y = size * 2
        }
        // добавляем надпись .systemFont(ofSize: 0.004)
        let text = "Рабочая\nплоскость"
        let meshText = MeshResource.generateText(text,
                                                 extrusionDepth: 0.0001,
                                                 font: .systemFont(ofSize: 0.0035),
                                                 containerFrame: .zero,
                                                 alignment: .center,
                                                 lineBreakMode: .byTruncatingTail)
        let materialText = UnlitMaterial(color: .blue)
        let entity = ModelEntity(mesh: meshText, materials: [materialText])
        entity.transform = Transform(pitch: -90 * .pi/180, yaw: 0, roll: 0)
        
        entity.transform.translation.x = -size / 2.5
        entity.transform.translation.y = 0.0001
        entity.transform.translation.z = size / 4
        entity.name = NameEntitys.text.name
        point.addChild(entity)
        point.addChild(stick)
        return point
    }
    
}
