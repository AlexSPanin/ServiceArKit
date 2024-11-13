//
//  CreatorTypicalModels.swift
//  ServiceArKit
//
//  Created by Александр Панин on 13.11.2024.
//
import Foundation
import RealityKit
import SwiftUI
import Metal

/// Для формирования типовых фигур
final class CreatorTypicalModels {
    static let shared = CreatorTypicalModels()
    private init() {}
    
    /// Формирование модели точки прицеливания
    /// - Parameters:
    ///   - name: системное имя модели точки прицеливания
    ///   - size: размер
    ///   - color: цвет
    /// - Returns: модель точки прицеливания
    func createdMovePoint(size: Float, color: UIColor) -> ModelEntity {
        let mesh = MeshResource.generatePlane(width: size, depth: size, cornerRadius: 1)
        let material = SimpleMaterial(color: color, isMetallic: false)
        let point = ModelEntity(mesh: mesh, materials: [material])
        return point
    }
    
    /// Формирование плоскости
    /// - Parameters:
    ///   - name: системное имя плоскости
    ///   - size: размер
    ///   - color: цвет
    ///   - opacity: прозрачность
    /// - Returns: модель плоскости
    func createdPlane(size: CGSize, color: UIColor, opacity: Float) -> ModelEntity {
        let mesh = MeshResource.generatePlane(width: Float(size.width), depth: Float(size.height), cornerRadius: 0)
        var imageMaterial = UnlitMaterial()
        
        if #available(iOS 15.0, *) {
            let opacity: CustomMaterial.Opacity = .init(floatLiteral: opacity)
            imageMaterial.color = .init(tint: color)
            imageMaterial.blending = .init(blending: .transparent(opacity: opacity))
        } else {
            let red = color.cgColor.components?[0] ?? 1.0
            let green = color.cgColor.components?[1] ?? 1.0
            let blue = color.cgColor.components?[2] ?? 1.0
            imageMaterial.baseColor = .init(_colorLiteralRed: Float(red), green: Float(green), blue: Float(blue), alpha: opacity )
        }
        let material = [imageMaterial]
        
        // создаем модель
        let sceneEntity = ModelEntity(mesh: mesh, materials: material)
        sceneEntity.generateCollisionShapes(recursive: true)
        return sceneEntity
    }
}

