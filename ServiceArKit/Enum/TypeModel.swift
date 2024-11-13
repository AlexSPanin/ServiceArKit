//
//  TypeModel.swift
//  ServiceArKit
//
//  Created by Александр Панин on 26.10.2024.
//

import Foundation

// временное перечисление категорий
enum TypeModel: Codable, CaseIterable {
    case fence              // ограждения
    case grass              // газоны
    case wall               // стены, перегородки, обой
    case floor              // полы, паркет
    case roof               // потолки
    case model              // готовые 3Д модели
    case home               // готовые 3Д модели домов
    case project            // проекты
    // индекс сортировки
    var sort: Int {
        switch self {
        case .fence: return 1
        case .grass: return 2
        case .wall: return 4
        case .floor: return 5
        case .model: return 0
        case .roof: return 7
        case .home: return 8
        case .project: return 9
        }
    }
    // метка для сохранения в карточках товара
    var label: String {
        switch self {
        case .fence: return "fence"
        case .grass: return "grass"
        case .wall: return "wall"
        case .floor: return "floor"
        case .model: return "entity"
        case .roof: return "roof"
        case .home: return "home"
        case .project: return "project"
        }
    }
    // описание для приложений
    var description: String {
        switch self {
        case .fence: return "Ограждения"
        case .grass: return "Газон"
        case .wall: return "Стены"
        case .floor: return "Пол"
        case .model: return "3D модель"
        case .roof: return "Потолок"
        case .home: return "Строения"
        case .project: return "Проекты"
        }
    }
    // признак вида прицеливания при установке true только точка
    var isEntityModel: Bool {
        switch self {
        case .model, .home, .project: return true
        default: return false
        }
    }
}


