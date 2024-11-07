//
//  NameEntitys.swift
//  ServiceArKit
//
//  Created by Александр Панин on 26.10.2024.
//

//MARK: - системные названия моделей
enum NameEntitys {
    // для лучей
    case entityLine            // линия до точки прицеливания
    case movePoint             // точка прицеливания
    case nodePoint             // точка прицеливания для обоев и полов
    case anchorMovePoint       // привязка точки прицеливания

    // для основной сцены
    case anchorScene           // привязка основной сцены
    case entityScene           // основная сцена
    
    // для ограждений
    case entityFence            // сцены вертикальных поверхностей
    case section                // секция для вертикальных поверхностей
    case rectangle              // элемент формирования вертикальной поверхности
    case text                   // элемент надписи
   
    // для покрытия
    case entityFloor             // сцены горизонтальных поверхностей
    case border                  // бордюры для горизонтальных поверхностей
    case polygon                 // полигоны для горизонтальных поверхностей
    
    var name: String {
        switch self {
        case .entityLine: return "add-line"
        case .movePoint: return "add-movePoint"
        case .nodePoint: return "add-nodePoint"
        case .anchorMovePoint: return "add-anchorMovePoint"
        case .anchorScene: return "sceneAnchor"
        case .entityScene: return "entityScene"
        case .entityFence: return "sceneFence"
        case .section: return "sectionFence"
        case .rectangle: return "add-rectangle"
        case .entityFloor: return "sceneFloor"
        case .border: return "add-border"
        case .polygon: return "polygonFloor"
        case .text: return "add-text"
        }
    }
}
