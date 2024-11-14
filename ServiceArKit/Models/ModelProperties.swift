//
//  ModelProperties.swift
//  ServiceArKit
//
//  Created by Александр Панин on 26.10.2024.
//

import Foundation
import RealityKit

struct ModelProperties: Codable {
    var id = UUID().uuidString                                                 // id entity
    var idVendor: String                                                       // id производителя
    var idCategory: String                                                     // id категории
    var idProduct: String                                                      // id карточки товара
    var idPre: String = ""                                                     // nameID головной entity
    var idAfter: [String] = []                                                 // массив nameID входящих entity
    
    var model: String                                                          // file usdz
    var modelGlb: String = ""                                                  // file glb
    var audio: [String] = []                                                   // массив наименований аудио файлов

    var nameID: String {"\(typeModel.label)|\(idProduct)|\(id)"}               // комплексное id передается в entity
    
    var typeModel: TypeModel                                                   // тип модели
    var parts: [ProductPart] = []                                              // массив слоев
    
    var baseY: Float                                                           // базовое сщещение по оси Y
    var simd_scene_first: simd_float4x4 = simd_float4x4()                      // simd начальный
    var simd_scene_save: simd_float4x4 = simd_float4x4()                       // simd сохраненный с последнего перемещения
    var simd_scene_old: simd_float4x4 = simd_float4x4()                        // simd архивный
    var simd_scene: simd_float4x4 = simd_float4x4()                            // simd текущий динамический
    
    var proprieties: [String: [String:String]] = [:]                           // резервный словарь
    //MARK: новые поля с переносом в новую модель
    var modelFields: [String: String] = ["typeModel" : "entity",
                                         "usdz" : "",
                                         "glb" : "",
                                         "scale" : String(Float(1.0)),
                                         "baseY" : String(Float(0.0))]          // словарь для полей модели для новой структуры
    var isEnableCancel: Bool { simd_scene_save != simd_scene }
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case idVendor = "idVendor"
        case idCategory = "idCategory"
        case idProduct = "idProduct"
        case idPre = "idPre"
        case idAfter = "idAfter"
        case model = "model"
        case modelGlb = "modelGlb"
        case audio = "audio"
        case typeModel = "typeModel"
        case parts = "parts"
        case baseY = "baseY"
        case simd_scene_first = "simd_scene_first"
        case simd_scene_save = "simd_scene_save"
        case simd_scene_old = "simd_scene_old"
        case simd_scene = "simd_scene"
        case proprieties = "proprieties"
        case modelFields = "modelFields"
        
    }
    
    init(idVendor: String, idCategory: String, idProduct: String, model: String,
         typeModel: TypeModel, baseY: Float) {
        self.idVendor = idVendor
        self.idCategory = idCategory
        self.idProduct = idProduct
        self.model = model
        self.typeModel = typeModel
        self.baseY = baseY
    }
    
    init (product: Product) {
        self.idVendor = product.idVendor
        self.idCategory = product.idCategory
        self.idProduct = product.id
        self.model = product.model
        self.typeModel = TypeModel.allCases.first(where: {$0.label == product.typeModel }) ?? .model
        self.baseY = product.basePositionY
        self.parts = product.elements
        self.audio = product.audio
        self.modelGlb = product.modelGlb
        self.modelFields = product.modelFields
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.idVendor = try container.decode(String.self, forKey: .idVendor)
        self.idCategory = try container.decode(String.self, forKey: .idCategory)
        self.idProduct = try container.decode(String.self, forKey: .idProduct)
        self.idPre = try container.decode(String.self, forKey: .idPre)
        self.idAfter = try container.decode([String].self, forKey: .idAfter)
        self.model = try container.decode(String.self, forKey: .model)
        do {
            self.modelGlb = try container.decode(String.self, forKey: .modelGlb)
        } catch {
            self.modelGlb = ""
        }
        self.audio = try container.decode([String].self, forKey: .audio)
        do {
            self.typeModel = try container.decode(TypeModel.self, forKey: .typeModel)
        } catch {
            self.typeModel = .model
        }
        self.parts = try container.decode([ProductPart].self, forKey: .parts)
        self.baseY = try container.decode(Float.self, forKey: .baseY)
        self.simd_scene_first = try container.decode(simd_float4x4.self, forKey: .simd_scene_first)
        self.simd_scene = try container.decode(simd_float4x4.self, forKey: .simd_scene)
        do {
            self.simd_scene_save = try container.decode(simd_float4x4.self, forKey: .simd_scene_save)
        } catch {
            self.simd_scene_save = self.simd_scene
        }
        self.simd_scene_old = try container.decode(simd_float4x4.self, forKey: .simd_scene_old)
       
        self.proprieties = try container.decode([String : [String : String]].self, forKey: .proprieties)
        
        do {
            self.modelFields = try container.decode([String : String].self, forKey: .modelFields)
        } catch {
            self.modelFields = ["typeModel" : "entity",
                                "usdz" : "",
                                "glb" : "",
                                "scale" : String(Float(1.0)),
                                "baseY" : String(Float(0.0))]
        }
    }
}
