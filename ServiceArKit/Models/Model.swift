//
//  Model.swift
//  ServiceArKit
//
//  Created by Александр Панин on 26.10.2024.
//

import SwiftUI
import RealityKit
import Combine
import AVFAudio


class Model {
    var card: Product
    var modelEntity: ModelEntity?                                                        // загруженная модель
    var selectAudio: String = ""                                                         // выбранный аудиофайл
    var value: Float = 0.0                                                               // индикатор загрузки
    var loadingFiles: [String : (TypeUpload, Bool)] = [:]                                // словарь файлов к загрузке с признаком локального наличия и местом загрузки
    var isColorButton: Bool = false                                                      // признак наличия кнопки выбора цвета
    var isShowRating: Bool = false                                                       // признак показа рейтинга
    var isChangeHeart: Bool = false { didSet { changeHeart() }}                          // переключение признака любимая модель
    var isLoadingFiles: Bool { loadingFiles.contains(where: {$0.value.1 == false})}      // признак что надо догрузить файлы
    var countFilesLoad: Int { loadingFiles.count }                                       // количество файлов к загрузке
    
    private var cancellable: AnyCancellable?
    private let network = NetworkManager.shared
    private let local = FileAppManager.shared
    
    init(card: Product) {
        self.card = card
        if card.id == "85A33CDB-F2CD-40B3-843B-4BC0DCA3078B" {
            printMessage("Card ID \(card.id)  иницилизирована Group ID \(card.idGroups)", isPrint: true)
        }
    }
    
    
    /// полная инициализация модели
    /// - Parameter completion: инициализированная модель
    func initModel(completion: @escaping (Model) -> Void ) {
        checkColorButton()
        chekFilesLoad() { message in completion(self) }
    }
    
    /// Формирование списка файлов модели к загрузке
    func chekFilesLoad(completion: @escaping (ErrorMessage) -> Void) {
        loadingFiles = [:]
        // файлы моделей
        let glb = self.card.modelGlb
        if !glb.isEmpty  { loadingFiles[glb] = (.glb,false) }
        let usdz = self.card.model
        if !usdz.isEmpty { loadingFiles[usdz] = (.usdz,false) }
        // аудио файлы
        self.card.audio.forEach { file in
            if !file.isEmpty { loadingFiles[file] = (.audio,false) }}
        // файлы текстур
        self.card.elements.forEach { element in
            element.textures.forEach { type, file in
                if type != "PR" && type != "SC" && !file.isEmpty { loadingFiles[file] = (.image, false) } }
            element.addTexture.forEach { texture in texture.value.forEach { type, file in
                if type != "PR" && type != "SC" && !file.isEmpty { loadingFiles[file] = (.image, false) } } }
        }
        loadingFiles[""] = nil                                                      // удалил пустые файлы
        
        // проверка наличия файлов
        guard !loadingFiles.isEmpty else { completion(.ok("файлы загрузки не нужны")); return }
        var count = loadingFiles.count
        loadingFiles.forEach { key, value in
            let status = local.checkExistFile(to: key, type: fileDirectory)
            self.loadingFiles[key] = (value.0,status)
            count -= 1
            if count == 0 { completion(.ok("файлы загрузки прошли проверку")) }
        }
    }
//    /// Изменение рейтинга
//    /// - Parameter rating: новый рейтинг
//    func setRating(to rating: Int) {
//        card.sum += rating
//        card.count += 1
//        card.rating = card.count != 0 ? String(format: "%.1f", Float(card.sum) / Float(card.count)) : ""
//        changeRating()
//    }
//    
    /// метод асинхронной загрузки 3D моделей
    /// - Parameters:
    ///   - library: библиотека Metall
    ///   - completion: опциональный комплишн
    func asyncLoadEntity(shader: CustomMaterial.SurfaceShader?, completion: @escaping (ErrorMessage) -> Void ) {
        // определяем типы и значения
        let fileName = self.card.model
        let type = self.card.typeModel
        let isLayers = self.card.isLayers
        let name = self.card.name[language] ?? "нет названия"
        printMessage("Начало загрузки Enity \(String(describing: self.card.name[language])) файл \(fileName) id \(self.card.id)")
        checkLocalFile(to: fileName) { url in
            guard let url = url else { return completion(.error("пустой адрес загрузки")) }
            self.cancellable = ModelEntity.loadAsync(contentsOf: url)
                .sink (receiveCompletion: { loadCompletion in
                    switch loadCompletion {
                    case .failure(let error):  completion(.error(error.localizedDescription))
                    case .finished: do {}
                    }
                })
            { entity in
                entity.name = name
                let modelEntity = ModelEntity()      // определяем родительское modelEntity
                modelEntity.addChild(entity)
                modelEntity.name = entity.name
                
                let entityBounds = entity.visualBounds(relativeTo: modelEntity)
                // для строений не устанавливаем коллизии взаимодействия
                if type != "home" {
                    // для строений не устанавливаем коллизии взаимодействия
                    modelEntity.collision = CollisionComponent(shapes: [ShapeResource.generateBox(size: entityBounds.extents).offsetBy(translation: entityBounds.center)])
                    modelEntity.generateCollisionShapes(recursive: true)
                } else {
                    // для Домов расчитали размер плоскости
                    let widthX = entityBounds.max.x - entityBounds.min.x
                    let widthZ = entityBounds.max.z - entityBounds.min.z
                    // расчитали вертикальное смещение плоскости
                    var offset = entityBounds.center
                    offset.y = entityBounds.min.y
                    // создали плоскость взаимодействия
                    modelEntity.collision = CollisionComponent(shapes: [ShapeResource.generateBox(width: widthX, height: 0.001, depth: widthZ).offsetBy(translation: offset)])
                }
                
                // если у модели есть слои то разворачиваем базовые цвета и текстуры
                if isLayers {
                   let myGroup = DispatchGroup()
                    self.card.elements.forEach { part in
                        let color = part.addColors.first(where: {$0.key == part.select || $0.key == part.start})?.value
                        let texture = part.addTexture.first(where: {$0.key == part.select || $0.key == part.start})?.value
                       myGroup.enter()
                        modelEntity.changeLayersFile(shader: shader,
                                                     color: color,
                                                     texture: texture ,
                                                     textures: part.textures,
                                                     namePart: part.namePart) { message in
                            printMessage(message.message)
                            myGroup.leave()
                        }
                    }
                    myGroup.notify(queue: .main) {
                        self.modelEntity = modelEntity
                        self.modelEntity?.scale *= self.card.scaleCompensation
                        self.modelEntity?.name = name
                        completion(.ok("Модель \(name) загружена"))
                    }
                } else {
                    self.modelEntity = modelEntity
                    self.modelEntity?.scale *= self.card.scaleCompensation
                    self.modelEntity?.name = name
                    completion(.ok("Модель \(name) загружена"))
                }
            }
        }
    }
}

//MARK: - приватные методы
extension Model {

    /// проверка наличия файла в локальном хранилище и перенос при необходимости
    /// - Parameters:
    ///   - name: имя файла
    ///   - completion: опциональный полный URL
    private func checkLocalFile(to name: String, completion: @escaping (URL?) -> Void) {
        guard let directory = fileDirectory.url, !name.isEmpty else { return completion(nil) }
        let url = directory.appendingPathComponent(name)
        printMessage("Восстановленный адрес \(url))")
        guard !local.checkExistFile(to: name, type: fileDirectory) else {  return completion(url)}
        printMessage("Файл не найден \(name)")
        network.loadFile(type: .usdz, file: name) { data in
            guard let data = data else { return completion(nil) }
            self.local.saveFileData(to: name, type: fileDirectory, data: data)
            self.loadingFiles[name] = (TypeUpload.usdz, true)
            completion(url)
        }
    }

    /// метод проверки наличия кнопки изменения цветов
    private func checkColorButton() {
        var checkColorButton = false
        card.elements.forEach { part in
            let showColor = part.show && !part.notShow
            checkColorButton = checkColorButton ? checkColorButton : showColor
        }
        isColorButton = checkColorButton
    }
    
    /// изменения статуса любимый
    private func changeHeart() {
//        guard let index = db.products.firstIndex(where: {$0.collection.id == card.collection.id}) else { return }
//        db.products[index].collection.showHeart = card.collection.showHeart
//        db.saveProducts()
    }
}
