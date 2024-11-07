//
//  TypeLayers.swift
//  ServiceArKit
//
//  Created by Александр Панин on 26.10.2024.
//

import Foundation

//MARK: - перечисление слоев составной части модели
enum TypeLayers: String, Codable, CaseIterable {
    case product = "PR"
    case baseColor = "BC"
    case emerssiveColor = "EC"
    case mettalic = "M"
    case roughness = "R"
    case normal = "N"
    case ao = "AO"
    case opacity = "O"
    case specular = "S"
    case scaling = "SC"
    
    var sort: Int {
        switch self {
        case .baseColor: return 1
        case .emerssiveColor: return 2
        case .mettalic: return 3
        case .roughness: return 4
        case .normal: return 5
        case .ao: return 7
        case .opacity: return 6
        case .specular: return 8
        case .product: return 0
        case .scaling: return 9
        }
    }
    
    var label: String {
        switch self {
        case .product: return "Значок"
        case .baseColor: return "BaseColor"
        case .emerssiveColor: return "EmerssiveColor"
        case .mettalic: return "Mettalic"
        case .roughness: return "Roughness"
        case .normal: return "Normal"
        case .ao: return "AO"
        case .opacity: return "Opacity"
        case .specular: return "Specular"
        case .scaling:  return "Масштаб текстуры"
        }
    }
}
