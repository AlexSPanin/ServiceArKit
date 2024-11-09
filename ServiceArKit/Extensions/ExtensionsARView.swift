//
//  ExtensionsARView.swift
//  ServiceArKit
//
//  Created by Александр Панин on 04.10.2024.
//
import SwiftUI
import RealityKit

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

    func placeEntity (_ entity: ModelEntity?, _ properties: ModelProperties?, position: SIMD3<Float>, completion: @escaping(ModelProperties?) -> Void) {
        guard let modelEntity = entity, var properties = properties else { return completion(properties) }
        printMessage("Добавляем модель \(modelEntity.name)")

        let clonedEntity = modelEntity.clone(recursive: true)                                        // скопировали модель
        clonedEntity.name = properties.nameID                                                        // добавили ид имя модели
        clonedEntity.position = position                                                              // получили из луча матрицу координат и позицию
        clonedEntity.scale *= Float(properties.modelFields["scale"] ?? "1.0") ?? 1.0                  // получили и масштаб и передали их моделе
        //    tappedEntity = clonedEntity                                                             // присваиваем tappedEntity новое значение для активации кнопки удаления объекта
        
        self.getScene { scene in
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
            //self.loadModel = nil                                                                              // временно потом надо будет убрать!!!!! перенести в сохранение проекта
            //self.selectedModel?.modelEntity = nil
            printMessage("Полученное положение модели  по Y \(position.y)")
            printMessage("Положение модели относительно сцены по Y \(simd.columns.3.y)")
            completion(properties)
        }
    }
    
    /// генерация общей сцены
    /// - Parameter simd: координаты плоскости определенные Raycast
    func drawScene(_ simd: simd_float4x4, isCheck: Bool, completion: @escaping(ErrorMessage) -> Void) {
        // создаем клон точки прицеливания для основной сцены
        let movePoint = self.getPointForEntity(EntitysName.point.rawValue, size: 0.025, color: .yellow)
        movePoint.position = [0,0,0]
        let pointAnchor = AnchorEntity(world: simd)
        pointAnchor.name = EntitysName.pointAnchor.rawValue
        pointAnchor.isEnabled = false
        pointAnchor.addChild(movePoint)
        
        // создаем прозрачную плоскость 10 на 10 метров средняя точка первая точка
        let color = UIColor.white
        let width: Float = 10
        let depth: Float = 10
        let mesh = MeshResource.generatePlane(width: width, depth: depth, cornerRadius: 0)
        let imageMaterial = UnlitMaterial(color: color.withAlphaComponent(0.0))
        let material = [imageMaterial]
        // создаем модель
        let sceneEntity = ModelEntity(mesh: mesh, materials: material)
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
        let scale = sceneAnchor.scale(relativeTo: sceneAnchor)
        let simd_anchor = sceneAnchor.transform.matrix
        //        project.simd_scene_anchor = simd_anchor
        //        project.simd_scene = simd_scene
        //        project.simd_scene_first = simd_scene
        //        project.scale_scene = scale
        //        project.scale_scene_first = scale
        //        project.isReady = true
        //        project.idUser = user?.id ?? ""
        printMessage("Сохраненные координаты точки наведения Anchor :\n   x - \(simd_anchor.position().x)\n   y - \(simd_anchor.position().y)\n   z - \(simd_anchor.position().z)")
        printMessage("Сохраненные координаты точки наведения Сцены :\n   x - \(simd_scene.position().x)\n   y - \(simd_scene.position().y)\n   z - \(simd_scene.position().z)")
        guard isCheck else {  return completion(.ok("Анкор без проверок на координаты")) }
        let check = simd_anchor.position().x == 0 && simd_anchor.position().y == 0 && simd_anchor.position().z == 0
        completion ( check ? .error("Нулевой Анкор") : .ok("Анкор не нулевой") )
    }
    
    /// удаляем все сущности и анкоры и снова добавляем FocusEntity
    func removeAllAnchors() {
        for anchor in self.scene.anchors {
            if !anchor.children.isEmpty { anchor.children.removeAll() }
            self.scene.removeAnchor(anchor)
        }
        self.scene.anchors.removeAll()
    }
    
    /// Изменение видимости точки прицеливания
    /// - Parameter status: статус
    func changeEnableMovePoint(to status: Bool) {
        guard let anchor = self.scene.anchors.first(where: {$0.name == EntitysName.pointAnchor.rawValue})  else { return }
        anchor.isEnabled = status
    }
    
    /// получаем anchor
    /// - Parameter compeation:  возвращает anchor
    func getAnchor(completion: @escaping(AnchorEntity?) -> Void) {
        completion(self.scene.anchors.first(where: {$0.name == EntitysName.anchor.rawValue}) as? AnchorEntity)
    }
    
    /// получаем сцену по якорю
    /// - Parameter compeation: возвращает модель сцены
    func getScene(completion: @escaping(ModelEntity?) -> Void) {
        getAnchor{ anchor in completion(anchor?.children.first (where: {$0.name == EntitysName.scene.rawValue }) as? ModelEntity) }
    }
    
    // MARK: - Приватные методы
    /// Формирование модели точки прицеливания
    /// - Parameters:
    ///   - name: системное имя модели точки прицеливания
    ///   - size: размер
    ///   - color: цвет
    ///   - nameStick: наименование модели указки
    /// - Returns: модель точки прицеливания
    private func getPointForEntity(_ name: String, size: Float, color: UIColor, nameStick: String? = nil) -> ModelEntity {
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
        entity.name = EntitysName.text.rawValue
        point.addChild(entity)
        point.addChild(stick)
        return point
    }
}

