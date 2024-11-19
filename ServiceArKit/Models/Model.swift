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
    var loadingFiles: [String : TypeUpload ] = [:]                                       // словарь файлов к загрузке с местом загрузки
    var isColorButton: Bool = false                                                      // признак наличия кнопки выбора цвета
    var isShowRating: Bool = false                                                       // признак показа рейтинга
    var isChangeHeart: Bool = false { didSet { changeHeart() } }                         // переключение признака любимая модель
    
    private var cancellable: AnyCancellable?
    
    init(card: Product) {
        self.card = card
        if card.id == "85A33CDB-F2CD-40B3-843B-4BC0DCA3078B" { printMessage("Card ID \(card.id)  иницилизирована Group ID \(card.idGroups)", isPrint: true) }
    }
    
    
    /// полная инициализация модели
    /// - Parameter completion: инициализированная модель
    func initModel(completion: @escaping (Model) -> Void ) {
        checkColorButton()
        chekFilesToLoad() { message in
            printMessage(message.message, isPrint: isPrinting)
            completion(self)
        }
    }
    
    /// Формирование списка файлов модели к загрузке
    func chekFilesToLoad(completion: @escaping (ErrorMessage) -> Void) {
        loadingFiles = [:]
        // файлы моделей
        if !self.card.modelGlb.isEmpty  { loadingFiles[self.card.modelGlb] = .glb }
        if !self.card.model.isEmpty { loadingFiles[self.card.model] = .usdz }
        // аудио файлы
        self.card.audio.forEach { file in if !file.isEmpty { loadingFiles[file] = .audio }}
        // файлы текстур
        self.card.elements.forEach { element in
            element.textures.forEach { type, file in
                if type != "PR" && type != "SC" && !file.isEmpty { loadingFiles[file] = .image } }
            element.addTexture.forEach { texture in texture.value.forEach { type, file in
                if type != "PR" && type != "SC" && !file.isEmpty { loadingFiles[file] = .image } } }
        }
        loadingFiles[""] = nil                                                      // удалил пустые файлы
        completion(.ok("составлен список файлов к загрузке"))
    }
    
    /// Проверка наличия файлов в локальном хранилище и дозагрузка их в случаее необходимости
    /// - Parameter completion: сообщение
    private func loadNetworkFiles(completion: @escaping (ErrorMessage) -> Void) {
        guard !loadingFiles.isEmpty else { return completion(.ok("нет файлов к загрузке")) }
        let myGroup = DispatchGroup()
        var errors: [ErrorMessage] = []
        loadingFiles.forEach {file, type in
            if !FileAppManager.shared.checkExistFile(to: file, type: fileDirectory) {
                myGroup.enter()
                NetworkManager.shared.loadFileWriteLocal(type: type, file: file, local: fileDirectory) { message in
                    switch message {
                    case .error(_): errors.append(message)
                    default: do {}
                    }
                    myGroup.leave() }
            }
        }
        myGroup.notify(queue: .main) {
            guard !errors.isEmpty else { return  completion(.ok("файлы загружены из сети в локальное хранилище")) }
            var label: String = ""
            errors.forEach { error in label += "\n\(error.message)" }
            completion(.error("\(label)\nфайлы не загружены из сети в локальное хранилище"))
        }
    }
    
    /// асинхронная загрузка модели с отработкой версии ios
    /// - Parameters:
    ///   - url: URL адрес файла модели
    ///   - completion: возвращает модель Entity
    private func asyncLoadEntity(_ url: URL?, completion: @escaping (Entity?) -> Void ) {
        guard let url = url else { return completion(nil) }
        if #available(iOS 18.0, *) {
            Task {
                do {
                    let entity = try await Entity.init(contentsOf: url)
                    completion(entity)
                } catch {
                    completion(nil)
                }
            }
        } else {
            self.cancellable = Entity.loadAsync(contentsOf: url)
                .sink (receiveCompletion: { loadCompletion in
                    switch loadCompletion {
                    case .failure(_):  completion(nil)
                    case .finished: do {}
                    }
                })
            { entity in  completion(entity) }
        }
    }
    
    
    /// метод асинхронной загрузки 3D моделей
    /// - Parameters:
    ///   - url: URL адрес файла модели
    ///   - shader:  библиотека Metall
    ///   - completion:  итоговое сообщение
    func asyncLoadModelEntity(shader: CustomMaterial.SurfaceShader?, completion: @escaping (ErrorMessage) -> Void ) {
        loadNetworkFiles { message in
            switch message {
            case .error(_): completion(message)
            default:
                // определяем типы и значения
                let fileName = self.card.model
                let type = self.card.typeModel
                let isLayers = self.card.isLayers
                let name = self.card.name[language] ?? "нет названия"
                printMessage("Начало загрузки Enity \(name) файл \(fileName) id \(self.card.id)")
                let url = fileDirectory.url?.appendingPathComponent(fileName)
                self.asyncLoadEntity(url) { entity in
                    guard let entity = entity else { return completion(.error("Модель \(name) не загружена"))}
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
                        printMessage("Enity \(name) со слоями начало разварачивания слоев \(self.card.elements.count)")
                        let myGroup = DispatchGroup()
                        self.card.elements.forEach { part in
                            let color = part.addColors.first(where: {$0.key == part.select || $0.key == part.start})?.value
                            let texture = part.addTexture.first(where: {$0.key == part.select || $0.key == part.start})?.value
                            myGroup.enter()
                            printMessage("\(part.namePart) ")
                            modelEntity.changeLayersFile(shader: shader,
                                                         color: color,
                                                         texture: texture ,
                                                         textures: part.textures,
                                                         namePart: part.namePart) { message in
                                printMessage(message.message, isPrint: true)
                                myGroup.leave()
                            }
                        }
                        myGroup.notify(queue: .main) {
                            self.modelEntity = modelEntity
                            self.modelEntity?.scale *= self.card.scaleCompensation
                            self.modelEntity?.name = name
                            completion(.ok("Модель \(name) со слоями загружена"))
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
}




//MARK: - приватные методы
extension Model {
    
    /// метод проверки наличия кнопки изменения цветов
    private func checkColorButton() {
        var checkColorButton = false
        card.elements.forEach { part in
            let showColor = part.show && !part.notShow
            checkColorButton = checkColorButton ? checkColorButton : showColor
        }
        isColorButton = checkColorButton
    }
    
    /// изменения статуса любимый переделать на изменение в массиве любимых у пользователя
    private func changeHeart() {
        //        guard let index = db.products.firstIndex(where: {$0.collection.id == card.collection.id}) else { return }
        //        db.products[index].collection.showHeart = card.collection.showHeart
        //        db.saveProducts()
    }
}
