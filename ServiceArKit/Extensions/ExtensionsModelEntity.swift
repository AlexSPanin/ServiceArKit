//
//  ExtensionsModelEntity.swift
//  ServiceArKit
//
//  Created by Александр Панин on 26.10.2024.
//

//  Created by Александр Панин on 25.11.2022.
//

import Foundation
import RealityKit
import SwiftUI
import Metal


// MARK: - расширения для ModelEntity
extension ModelEntity {
    func getJointIndex(suffix: String) -> Int? {
        return jointNames
            .enumerated()
            .first(where: { $0.element.hasSuffix(suffix) })?
            .offset
    }

//    /// изменение прозрачности слоя
//    /// - Parameters:
//    ///   - file: наименования файла текстуры прозрачности слоя модели илифайл установки  прозрачности
//    ///   - namePart: наименование части (слоя) модели к которой применяется признак прозрачности
//    func changeTransparent(to file: String, namePart: String, completion: @escaping(ErrorMessage) -> Void) {
//        printMessage("Изменить прозрачность слоя модели \(namePart)  \(file)")
//        guard !file.isEmpty else { return completion(.error("пустое название файла прозрачности"))}
//        guard let modelEntity = self.findEntity(named: namePart) as? ModelEntity else { return completion(.error("не получена часть модели"))}
//        guard let physicall = modelEntity.model?.materials.first as? PhysicallyBasedMaterial else { return completion(.error("не получен слой материала"))}
//        checkFile(to: file) { url in
//            guard let url = url else { return completion(.error("пустой URL адрес, нет файла ")) }
//            let id = UUID().uuidString
//            self.setOpacity(id: id, physicall: physicall, url: url) { physicall in
//                modelEntity.model?.materials[0] = physicall
//                completion(.ok("слой прозрачности успешно заменен для \(namePart)"))
//            }
//        }
//    }
    
    /// изменение прозрачности слоя
    /// - Parameters:
    ///   - file: наименования файла текстуры прозрачности слоя модели илифайл установки  прозрачности
    ///   - namePart: наименование части (слоя) модели к которой применяется признак прозрачности
    func isChangeEnablePart(isEnable: Bool, namePart: String, completion: @escaping(ErrorMessage) -> Void) {
        printMessage("Изменить прозрачность слоя модели \(namePart)")
        guard let modelEntity = self.findEntity(named: namePart) as? ModelEntity else { return completion(.error("не получена часть модели"))}
        modelEntity.isEnabled = isEnable
        completion(.ok("переключение прозрачности"))
    }
    
    private func checkTextureFiles(addTexture: [String : String]?,
                                   partTexture: [String : String],
                                   completion: @escaping([Int: URL?]) -> Void) {
        printMessage("Начало формирования файлов текстур для слоев материала")
        let myGroup = DispatchGroup()
        let types = TypeLayers.allCases.filter({ $0 != .product && $0 != .scaling }).sorted(by: {$0.sort < $1.sort})
        var files: [Int: URL?] = [:]
        types.forEach { type in
            var file: String = ""
            if let partTexture = partTexture[type.rawValue] {
                printMessage("Выбран файл из установочных настоек части модели \(partTexture)")
                file = partTexture
            }
            if let addTexture = addTexture?[type.rawValue] {
                printMessage("Выбран файл из коллекций цветов или текстур \(addTexture)")
                file = addTexture
            }
            
            if !file.isEmpty {
                myGroup.enter()
                checkFile(to: file) { url in
                    files[type.sort] = url
                    myGroup.leave()
                }
            }
        }
        myGroup.notify(queue: .main) { completion(files) }
    }
    
    // перезаписываем model component
    private func changePhysicallyBasedMaterial(physically: PhysicallyBasedMaterial,
                                               addTexture: [String : String]?,
                                               partTexture: [String : String],
                                               color: String?, completion: @escaping(PhysicallyBasedMaterial) -> Void) {
        checkTextureFiles(addTexture: addTexture, partTexture: partTexture) { files in
            printMessage("Начало применения слоев материала")
            var physically = physically
            
            let serialQueue = DispatchQueue(label: "changePhysicallyBasedMaterial")
            serialQueue.sync {
                guard let url = files[1] else { return }
                self.setBaseColor(id: UUID().uuidString, physicall: physically, url: url, color: color) { material in
                    physically = material
                }
            }
            
            serialQueue.sync {
                guard let url = files[2] else { return  }
                self.setEmissiveColor(id: UUID().uuidString, physicall: physically, url: url) { material in
                    physically = material
                }
            }
            serialQueue.sync {
                guard let url = files[3] else { return  }
                self.setMetallic(id: UUID().uuidString, physicall: physically, url: url) { material in
                    physically = material
                }
            }

            serialQueue.sync {
                guard let url = files[4] else { return }
                self.setRoughness(id: UUID().uuidString, physicall: physically, url: url) { material in
                    physically = material
                }
            }
            
            serialQueue.sync {
                guard let url = files[5] else { return  }
                self.setNormal(id: UUID().uuidString, physicall: physically, url: url) { material in
                    physically = material
                }
            }
            
            serialQueue.sync {
                guard let url = files[6] else { return  }
                self.setOpacity(id: UUID().uuidString, physicall: physically, url: url) { material in
                    physically = material
                }
            }
            
            serialQueue.sync {
                guard let url = files[7] else { return  }
                self.setAO(id: UUID().uuidString, physicall: physically, url:  url) { material in
                    physically = material
                }
            }
            
            serialQueue.sync {
                guard let url = files[8] else { return  completion(physically)}
                self.setSpecular(id: UUID().uuidString, physicall: physically, url: url) { material in
                    completion(material)
                }
            }
        }
    }
    
    private func createdLayersMaterials(modelComponent: ModelComponent,
                                        addTexture: [String : String]?, partTexture: [String : String],
                                        color: String?, scaling: Bool, completion: @escaping(ModelComponent) -> Void) {
        var modelComponent = modelComponent
        if modelComponent.materials.count == 1 {
            printMessage("В наличии один слой материала")
            guard var physicall = modelComponent.materials.first as? PhysicallyBasedMaterial else { return completion(modelComponent) }
            changePhysicallyBasedMaterial(physically: physicall, addTexture: addTexture, partTexture: partTexture, color: color) { material in
                physicall = material
                physicall.textureCoordinateTransform.scale = SIMD2(x: 1, y: 1)
                modelComponent.materials[0] = physicall
                guard scaling else { return completion(modelComponent) }
                printMessage("добавили базовый физический слой в массив материалов")
                modelComponent.materials.append(physicall)
                completion(modelComponent)
            }
        } else {
            printMessage("В наличии несколько слоев материала")
            guard var physicall = modelComponent.materials[1] as? PhysicallyBasedMaterial else { return completion(modelComponent) }
            changePhysicallyBasedMaterial(physically: physicall, addTexture: addTexture, partTexture: partTexture, color: color) { material in
                physicall = material
                physicall.secondaryTextureCoordinateTransform.scale = SIMD2(x: 1, y: 1)
                physicall.textureCoordinateTransform.scale = SIMD2(x: 1, y: 1)
                modelComponent.materials[0] = physicall
                completion(modelComponent)
            }
        }
    }
    
    
    // смена набора слоем указанной части модели
    func changeLayersFile(shader: CustomMaterial.SurfaceShader?, color: String?,
                          texture: [String : String]?,
                          textures: [String : String],
                          namePart: String, completion: @escaping(ErrorMessage) -> Void) {
        guard let modelEntity = self.findEntity(named: namePart) as? ModelEntity else { return completion(.error("не найдена часть модели"))}
        guard var oldModelComponent = modelEntity.model else { return completion(.error("не получена сама модель"))}
        var scaling: Float = 1.0
        if let value = textures[TypeLayers.scaling.rawValue], let scale = Float(value) {
            scaling = scale
            printMessage("Применяем установочный масштаб для выбранной части модели \(namePart) масштаб \(scaling)")
        }
        if let value = texture?[TypeLayers.scaling.rawValue], let scale = Float(value) {
            scaling = scale
            printMessage("Применяем масштаб для выбранной текстуры / цвета \(namePart) масштаб \(scaling)")
        }
       
        createdLayersMaterials(modelComponent: oldModelComponent, addTexture: texture, partTexture: textures, color: color, scaling: scaling != 1) { component in
            oldModelComponent = component
            guard scaling > 1.0 else { modelEntity.model = oldModelComponent; return  completion(.message("специальное увеличение не задано разворачиваем простую модель")) }
            guard let physicall = oldModelComponent.materials.first as? PhysicallyBasedMaterial else  { return completion(.error("не получен физический слой материала"))}
            guard let shader = shader else { return completion(.error("фатальная ошибка подготовки metal shader.")) }
            printMessage("Загрузка функций обработки: surface shader function named DissolveSurfaceShader")
            printMessage("Применяем выбранный масштаб для \(namePart) масштаб \(scaling)")
            do {
                var custom = try CustomMaterial(from: physicall, surfaceShader: shader)
                custom.textureCoordinateTransform.scale = SIMD2(x: scaling, y: scaling)
                custom.custom.value = SIMD4(scaling, scaling, scaling, scaling)
                oldModelComponent.materials[0] = custom
                modelEntity.model = oldModelComponent
                completion(.ok("новые компоненты добавлены"))
            } catch {
                modelEntity.model = oldModelComponent
                completion(.error("новый материал не развернут \(error.localizedDescription)"))
            }
        }
    }
    
    
    
    
    //MARK: - private metods
    // проверка наличия файла возвращает URL
    private func checkFile(to file: String, completion: @escaping (URL?) -> Void) {
        guard let directory = fileDirectory.url else { return completion(nil) }
        if FileAppManager.shared.checkExistFile(to: file, type: fileDirectory) {
             completion(directory.appendingPathComponent(file))
        } else {
            NetworkManager.shared.loadFileWriteLocal(type: .image, file: file, local: fileDirectory) { message in
                printMessage(message.message)
                switch message {
                case .ok(_):  completion(directory.appendingPathComponent(file))
                default: completion(nil)
                }
               
            }
        }
    }
    // установка цвета либо UIColor либо файл
    private func setBaseColor (id: String, physicall: PhysicallyBasedMaterial, url: URL?, color: String?, completion: @escaping (PhysicallyBasedMaterial) -> Void) {
        guard let url = url else { printMessage("ОШИБКА URL для BaseColor"); return completion(physicall) }
        guard let baseResource = try? TextureResource.load(contentsOf: url, withName: id) else {printMessage("ОШИБКА загрузки текстуры для BaseColor"); return completion(physicall) }
        var physicall = physicall
        let baseColor = MaterialParameters.Texture(baseResource)
        if let color = color {
            printMessage("BC востанавливаем по цвету и текстуре")
            let uiColor = UIColor(hex: color)
            let physicallyBaseColor = PhysicallyBasedMaterial.BaseColor(tint: uiColor , texture: baseColor)
            physicall.baseColor = physicallyBaseColor
            completion(physicall)
        } else {
            printMessage("BC востанавливаем по текстуре")
            let physicallyBaseColor = PhysicallyBasedMaterial.BaseColor(texture: baseColor)
            physicall.baseColor = physicallyBaseColor
            completion(physicall)
        }
    }
    
    // установка излучаещего света
    private func setEmissiveColor (id: String, physicall: PhysicallyBasedMaterial, url: URL?, completion: @escaping (PhysicallyBasedMaterial) -> Void) {
        guard let url = url else { printMessage("ОШИБКА URL для EmissiveColor"); return completion(physicall) }
        guard let emissiveResource = try? TextureResource.load(contentsOf: url, withName: id) else { printMessage("ОШИБКА загрузки текстуры для EmissiveColor"); return completion(physicall) }
        printMessage("установка излучаещего света")
        var physicall = physicall
        let emissiveMap = MaterialParameters.Texture(emissiveResource)
        physicall.emissiveColor = .init(texture: emissiveMap)
        completion(physicall)
        
    }
    // установка металлического блеска
    private func setMetallic (id: String, physicall: PhysicallyBasedMaterial, url: URL?, completion: @escaping (PhysicallyBasedMaterial) -> Void) {
        guard let url = url else { printMessage("ОШИБКА URL для Metallic"); return completion(physicall) }
        guard let metalResource = try? TextureResource.load(contentsOf: url, withName: id) else  { printMessage("ОШИБКА загрузки текстуры для Metallic"); return  completion(physicall) }
        printMessage("установка металлического блеска")
        var physicall = physicall
        let metallic = MaterialParameters.Texture(metalResource)
        physicall.metallic = PhysicallyBasedMaterial.Metallic(texture: metallic)
        completion(physicall)
    }
    // установка шероховатости поверхности
    private func setRoughness (id: String, physicall: PhysicallyBasedMaterial, url: URL?, completion: @escaping (PhysicallyBasedMaterial) -> Void) {
        guard let url = url else { printMessage("ОШИБКА URL для Roughness"); return completion(physicall) }
        guard let roughnessResource = try? TextureResource.load(contentsOf: url, withName: id) else {  printMessage("ОШИБКА загрузки текстуры для Roughness"); return completion(physicall) }
        printMessage("установка шероховатости поверхности ")
        var physicall = physicall
        let roughness = MaterialParameters.Texture(roughnessResource)
        physicall.roughness = PhysicallyBasedMaterial.Roughness(texture: roughness)
        completion(physicall)
        
    }
    
    // установка карты нормалей"
    private func setNormal (id: String, physicall: PhysicallyBasedMaterial, url: URL?, completion: @escaping (PhysicallyBasedMaterial) -> Void) {
        guard let url = url else { printMessage("ОШИБКА URL для Normal"); return completion(physicall) }
        guard let normalResource = try? TextureResource.load(contentsOf: url, withName: id) else {  printMessage("ОШИБКА загрузки текстуры для Normal"); return completion(physicall) }
        printMessage("установка карты нормалей")
        var physicall = physicall
        let normalMap = MaterialParameters.Texture(normalResource)
        physicall.normal = PhysicallyBasedMaterial.Normal(texture:normalMap)
        completion(physicall)
    }
    
    // установка затемнений для реалистичности объекта
    private func setAO (id: String, physicall: PhysicallyBasedMaterial, url: URL?, completion: @escaping (PhysicallyBasedMaterial) -> Void) {
        guard let url = url else { printMessage("ОШИБКА URL для AO"); return completion(physicall) }
        guard let aoResource = try? TextureResource.load(contentsOf: url, withName: id) else { printMessage("ОШИБКА загрузки текстуры для AO"); return completion(physicall) }
        printMessage("установка затемнений для реалистичности объекта")
        let aoMap = MaterialParameters.Texture(aoResource)
        var physicall = physicall
        physicall.ambientOcclusion = .init(texture: aoMap)
        completion(physicall)
    }
    
    // установка прозрачности
    private func setOpacity (id: String, physicall: PhysicallyBasedMaterial, url: URL?, completion: @escaping (PhysicallyBasedMaterial) -> Void) {
        guard let url = url else { printMessage("ОШИБКА URL для Opacity"); return completion(physicall) }
        guard  let opacityResource = try? TextureResource.load(contentsOf: url, withName: id) else { printMessage("ОШИБКА загрузки текстуры для Opacity"); return  completion(physicall) }
        printMessage("установка прозрачности")
        let opacityMap = MaterialParameters.Texture(opacityResource)
        var physicall = physicall
        physicall.blending = .transparent(opacity: .init(texture: opacityMap))
        completion(physicall)
    }

    /// установка зеркального отражения
    /// - Parameters:
    ///   - physicall: материал
    ///   - url: адрес файла
    ///   - completion: возвращаем материал
    private func setSpecular (id: String, physicall: PhysicallyBasedMaterial, url: URL?, completion: @escaping (PhysicallyBasedMaterial) -> Void) {
        guard let url = url else { printMessage("ОШИБКА URL для Specular"); return completion(physicall) }
        guard let specularResource = try? TextureResource.load(contentsOf: url, withName: id) else { printMessage("ОШИБКА загрузки текстуры для Specular"); return completion(physicall) }
        printMessage("установка зеркального отражения")
        let specularMap = MaterialParameters.Texture(specularResource)
        var physicall = physicall
        physicall.specular = .init(texture: specularMap)
        completion(physicall)
    }
}


