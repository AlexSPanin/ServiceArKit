//
//  ExtensionsARView.swift
//  ServiceArKit
//
//  Created by Александр Панин on 04.10.2024.
//
import SwiftUI
import RealityKit
import Combine
import ARKit


extension ARView {
    
    /// системные названия моделей
    enum EntitysName: String {
        // для лучей
        case line = "line"                // линия до точки прицеливания
        case point = "point"              // точка прицеливания
        case node = "node"                // точка прицеливания для обоев и полов
        case pointAnchor = "pointAnchor"  // привязка точки прицеливания

        // для основной сцены
        case anchor = "anchor"             // привязка основной сцены
        case scene = "scene"               // основная сцена
        
        // для ограждений
        case fence = "fence"               // сцены вертикальных поверхностей
        case section = "section"           // секция для вертикальных поверхностей
        case rectangle = "rectangle"       // элемент формирования вертикальной поверхности
        case text  = "text"                // элемент надписи
       
        // для покрытия
        case entityFloor = "floor"         // сцены горизонтальных поверхностей
        case border = "border"             // бордюры для горизонтальных поверхностей
        case polygon = "polygon"           // полигоны для горизонтальных поверхностей
    }

    
    /// конфигурируем БЕЗ определением горизонтальной плоскости, после того, как плоскость найдена, дольше плоскости не ищем
    func configureNonPlane() {
        printMessage("Начало конфигурации БЕЗ определения плоскости работы", isPrint: isPrinting)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        self.environment.lighting.intensityExponent = 2
        self.session.run(configuration)
    }
    
    /// конфигурируем со сбросом всех заранее найденных плоскостей и с определением горизонтальной плоскости
    func configureTracking() {
        printMessage("Начало конфигурации с определением плоскости работы", isPrint: isPrinting)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) { configuration.sceneReconstruction = .mesh }
        configuration.prepareForInterfaceBuilder()
        self.environment.lighting.intensityExponent = 2
        self.session.run(configuration)
    }
    
    /// конфигурируем со сбросом всех заранее найденных плоскостей и с определением горизонтальной плоскости
    func configureResetTracking() {
        printMessage("Сброс конфигурации плоскости работы", isPrint: isPrinting)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) { configuration.sceneReconstruction = .mesh }
        configuration.prepareForInterfaceBuilder()
        self.environment.lighting.intensityExponent = 2
        self.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    /// управление лидаром
    /// - Parameter isEnabled: true - включен
    func toggleShowLidar(_ isEnabled: Bool) {
        guard ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) else { return }
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        if isEnabled  {
            configuration.sceneReconstruction = .mesh
            self.environment.sceneUnderstanding.options.insert([.occlusion])
        } else {
            self.environment.sceneUnderstanding.options.remove([.occlusion])
        }
        self.session.run(configuration)
    }
    
    /// отрисовка точки прицеливания
    /// - Parameter p: точка на экране по умолчанию середина экрана
    func movePoint() {
        self.positionMovePoint(self.getRaycast(midPoint))
    }
    
    /// обработчик луча проверка горизонтальной плоскости
    /// - Parameter point: точка луча
    /// - Returns: nil - не прошел запрос, 0 - последняя плоскость не получена,  simd - корректный результат
    func getRaycast(_ point: CGPoint) -> simd_float4x4? {
        let query = self.makeRaycastQuery(from: point, allowing: .existingPlaneInfinite, alignment: .horizontal)
        guard let firstResult = query else { return nil }
        let results = self.session.raycast(firstResult)
        guard let position = results.last?.worldTransform else { return simd_float4x4() }
        return position
    }
    
    func getPartsEntity(_ model: String?, parts: [String] , completion: @escaping([ModelEntity]) -> Void) {
        guard !parts.isEmpty else { return completion([]) }
        getEntity(model) { model in
            guard let model = model else { return completion([]) }
            var models: [ModelEntity] = []
            parts.forEach { part in
                if let modelEntity = model.findEntity(named: part) as? ModelEntity {
                    models.append(modelEntity)
                }
            }
            completion(models)
        }
    }
    
    func getEntity(_ name: String?, completion: @escaping(ModelEntity?) -> Void) {
        getModelEntity(.anchor, .scene) { scene in
            guard let name = name, let model = scene?.findEntity(named: name) as? ModelEntity else { return completion(nil) }
            completion(model)
        }
    }
    
    
    
    
    func placeEntity (_ entity: ModelEntity?, _ properties: ModelProperties?, simd: simd_float4x4?, completion: @escaping(ModelProperties?) -> Void) {
        guard let modelEntity = entity, var properties = properties , let position = simd?.position() else { return completion(nil) }
        printMessage("Добавляем модель \(modelEntity.name)")
        
        let clonedEntity = modelEntity.clone(recursive: true)                                        // скопировали модель
        clonedEntity.name = properties.nameID                                                        // добавили ид имя модели
        clonedEntity.position = position                                                              // получили из луча матрицу координат и позицию
        clonedEntity.scale *= Float(properties.modelFields["scale"] ?? "1.0") ?? 1.0                  // получили и масштаб и передали их моделе
        //    tappedEntity = clonedEntity                                                             // присваиваем tappedEntity новое значение для активации кнопки удаления объекта
        
        getModelEntity(.anchor, .scene) { scene in
            guard let scene = scene else { return completion(properties) }
            scene.addChild(clonedEntity, preservingWorldTransform: true)
            var simd = clonedEntity.transformMatrix(relativeTo: scene)
            simd.columns.3.y = simd.columns.3.y < -yPositionScene ? -yPositionScene : simd.columns.3.y  // если установка по высоте ниже уровня плоскости, то ставим уровень плоскости
            simd.columns.3.y += Float(properties.modelFields["baseY"] ?? "0.0") ?? 0.0                  // если прописано в установках приподняли модель
            clonedEntity.setTransformMatrix(simd, relativeTo: scene)
            // установили стартовые позиции установки
            properties.simd_scene_first = simd
            properties.simd_scene_save = simd
            properties.simd_scene_old = simd
            properties.simd_scene = simd
            //self.installGesturesEntity(to: self.tappedEntity)                                                 // добавляем распознование жестов
            printMessage("Полученное положение модели  по Y \(position.y)")
            printMessage("Положение модели относительно сцены по Y \(simd.columns.3.y)")
            completion(properties)
        }
    }
    
    /// генерация общей сцены
    /// - Parameters:
    ///   - simd: координаты
    ///   - point: модель точки прицеливания
    ///   - scene: модель сцены
    ///   - isCheck: признак проверки на 0 анкор
    ///   - completion: сообщение о результате
    func drawScene(_ simd: simd_float4x4, point: ModelEntity, scene: ModelEntity, isCheck: Bool, completion: @escaping(ErrorMessage) -> Void) {
        // создаем клон точки прицеливания для основной сцены
        let movePoint = point.clone(recursive: true)
        movePoint.name = EntitysName.point.rawValue
        movePoint.position = [0,0,0]
        
        let pointAnchor = AnchorEntity(world: simd)
        pointAnchor.name = EntitysName.pointAnchor.rawValue
        pointAnchor.isEnabled = false
        pointAnchor.addChild(movePoint)
        
        // создаем прозрачную плоскость 10 на 10 метров средняя точка первая точка
        let sceneEntity = scene.clone(recursive: true)
        sceneEntity.name = EntitysName.scene.rawValue
        sceneEntity.position = [0,yPositionScene,0]
        sceneEntity.generateCollisionShapes(recursive: true)
        
        // создаем анкор привязку
        let sceneAnchor = AnchorEntity(plane: .horizontal)
        sceneAnchor.name = EntitysName.anchor.rawValue
        sceneAnchor.addChild(sceneEntity)
        
        // размещаем анкор в основном вью
        printMessage("Название сцены \(sceneEntity.name) Название Анкора \(sceneAnchor.name)")
        self.scene.addAnchor(sceneAnchor)
        self.scene.addAnchor(pointAnchor)
        // сохраняем в проекте матрицы анкора и общей сцены и устанавливаем признак готовности
        let simd_scene = sceneEntity.transformMatrix(relativeTo: sceneAnchor)
        let simd_anchor = sceneAnchor.transform.matrix
        printMessage("Сохраненные координаты точки наведения Anchor :\n   x - \(simd_anchor.position().x)\n   y - \(simd_anchor.position().y)\n   z - \(simd_anchor.position().z)")
        printMessage("Сохраненные координаты точки наведения Сцены :\n   x - \(simd_scene.position().x)\n   y - \(simd_scene.position().y)\n   z - \(simd_scene.position().z)")
        if #available(iOS 18.0, *) {
            completion(.ok("Анкор без проверок на координаты"))
        } else {
            guard isCheck else { completion(.ok("Анкор без проверок на координаты")); return }
            let check = simd_anchor.position().x == 0 && simd_anchor.position().y == 0 && simd_anchor.position().z == 0
            completion ( check ? .error("Нулевой Анкор") : .ok("Анкор не нулевой") )
        }
    }
    
    
    
    
    
    /// получаем anchor
    /// - Parameter anchor: имя анкора
    /// - Parameter completion: AnchorEntity?
    private func getAnchorEntity(_ anchor: EntitysName, completion: @escaping(AnchorEntity?) -> Void) {
        completion(self.scene.anchors.first(where: {$0.name == anchor.rawValue}) as? AnchorEntity)
    }
    
    /// получаем сцену по якорю
    /// - Parameter anchor: тип анкора
    /// - Parameter model: тип модели
    /// - Parameter completion: ModelEntity?
    private func getModelEntity(_ anchor: EntitysName, _ model: EntitysName, completion: @escaping(ModelEntity?) -> Void) {
        getAnchorEntity(anchor){ anchor in completion(anchor?.children.first (where: {$0.name == model.rawValue }) as? ModelEntity) }
    }
    
    /// удаляем все сущности и анкоры и снова добавляем FocusEntity
    func removeAllAnchors() {
        for anchor in self.scene.anchors {
            anchor.children.removeAll()
            self.scene.removeAnchor(anchor)
        }
        self.scene.anchors.removeAll()
    }
    
    
    /// Изменение видимости точки прицеливания
    /// - Parameter status: статус
    func enableMovePoint(_ isEnable: Bool) {
        getAnchorEntity(.pointAnchor) { anchor in anchor?.isEnabled = isEnable  }
    }
    
    /// Изменение позиции точки прицеливания
    /// - Parameter simd: матрица координат
    func positionMovePoint(_ simd: simd_float4x4?) {
        guard let simd = simd else { return }
        printMessage("Новая позиция \(simd.position())", isPrint: false)
        getAnchorEntity(.pointAnchor) { anchor in anchor?.setTransformMatrix(simd, relativeTo: nil) }
    }
    
    /// Определение дистанции до точки прицеливания
    /// - Parameter simd: мартица точки прицеливания
    func createdDistance(to simd: simd_float4x4) -> Float {
        guard let simdCamera = self.session.currentFrame?.camera.transform else { return 0.0 }
        let anchorPosition = simd.columns.3
        let cameraPosition = simdCamera.columns.3
        let cameraToAnchor = cameraPosition - anchorPosition
        return length(cameraToAnchor)
    }
    


}

