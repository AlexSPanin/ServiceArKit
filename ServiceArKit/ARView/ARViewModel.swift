//
//  ARViewModel.swift
//  ServiceArKit
//
//  Created by Александр Панин on 22.10.2024.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

final class ARViewModel: ObservableObject {
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
    enum TypeRaycastError {
        case no, querry, result
    }
    
    enum StatusAPP {
        case loadView             // запуск приложения
        case initDB               // инициализация базы данных
        case endInit              // окончание инициализации после фонового определения плоскости
        case firstSearth          // запуск фонового поиска плоскостей
        case checkSearth          // проверка корректности поиска сцены
        case isScene              // плоскость найдена
    }
    
    enum Status: Codable {
        case start                // режим работы AR View без обзервера
        case searth               // режим ожидания поиска плоскости
        case add                  // режим добавления
        case edit                 // режим редактирования
        case debug                // режим отладки
    }
    
    @Published var arView: ARView!                                                           // основное вью
    @Published var notification: NotificationAlert?                                          // окна уведомления
    @Published var statusAPP: StatusAPP = .loadView { didSet { changeStatusAPP() }}          // статус работы приложения
    @Published var statusScene: Status = .start { didSet { changeStatusScene()  } }          // статус сцены редактиование, добавление
    //MARK: - публикация ошибок поиска плоскости или точки
    @Published var errorMovePoint: Bool = false                                              // ошибка отрисовки подвижной точки
    @Published var errorMoveNode: Bool = false                                               // ошибка отрисовки подвижной ноды
    //MARK: - выбранные, загруженные
//    @Published var selectedModel: Model?                                                   // выбранная и уже загруженная модель из каталога
    var sceneObserver: Cancellable?                                                          // управление включением и выключением обзервера
    var isSupportSceneReconstruction: Bool = false                                           // признак реконструкции сцены лидаром
    let coachingOverlay = ARCoachingOverlayView()                                            // управление поиском плоскостей
    
    private let isPrint: Bool = false                                                        // признак печати уведомлений
    
    init() {
        printMessage("Инициализация ARViewModel", isPrint: isPrint)
        arView = ARView(frame: .zero)
//        configure()
    }
    
    func createdModel() {
                    // Create a cube model
                    let model = Entity()
                    let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
                    let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
                    model.components.set(ModelComponent(mesh: mesh, materials: [material]))
                    model.position = [0, 0.05, 0]
        
                    // Create horizontal plane anchor for the content
                    let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
                    anchor.addChild(model)
        
                    // Add the horizontal plane anchor to the scene
        arView.scene.addAnchor(anchor)
//        arView.cameraMode = .ar
    }
    
    /// конфигурируем с определением горизонтальной плоскости
    func configure() {
        guard Permissions.shared.checkPermissions(type: .video) else { notification = .deniedCamera; return }
        printMessage("Начало конфигурации плоскости работы", isPrint: isPrint)
        notification = .isConfigARView
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
            isSupportSceneReconstruction = true
        }
        configuration.prepareForInterfaceBuilder()
        arView.session.run(configuration)
        addCoachingOverlay(false)
 //       createdModel()
        initObserverRaycast(false)
    }
    
    /// Запуск поиска плоскости в ARView
    /// - Parameter isAnimation: признак анимированного поиска
    func addCoachingOverlay(_ isAnimation: Bool) {
        printMessage("Запуск поиска горизонтальной плоскости", isPrint: isPrint)
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.activatesAutomatically = true                        // включили поиск плоскостей
        coachingOverlay.setActive(true, animated: isAnimation)
        arView.addSubview(coachingOverlay)
    }
    
    /// конфигурируем со сбросом всех заранее найденных плоскостей и с определением горизонтальной плоскости
    func configureResetTracking() {
        notification = .isSearthPlane
        printMessage("Начало удаления всех плоскостей", isPrint: isPrint)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
            isSupportSceneReconstruction = true
        }
        configuration.prepareForInterfaceBuilder()

        arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        printMessage("Конец удаления всех плоскостей", isPrint: isPrint)
        addCoachingOverlay(true)
        initObserverRaycast(true)
    }
    

    /// конфигурируем БЕЗ определением горизонтальной плоскости, после того, как плоскость найдена, дольше плоскости не ищем
    func configureNonPlane() {
        printMessage("Начало конфигурации БЕЗ плоскости работы", isPrint: isPrint)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        arView.environment.lighting.intensityExponent = 2
        arView.session.run(configuration)
        printMessage("Конец конфигурации БЕЗ плоскости работы", isPrint: isPrint)
    }
    
    /// Инициализатор обзервера луча
    func initObserverRaycast(_ isCheck: Bool) {
        printMessage("Запус обзервера с проверкой наличия сцены", isPrint: isPrint)
        sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, {(event) in self.checkPlace(isCheck) })
    }
    
    /// метод подписки на обновление сцены
    /// - Parameter note: сообщение к печати уведомления
    func initSceneObserver(note: String) {
        guard  statusScene == .add && statusAPP == .isScene else { return }
        printMessage("Инициализация SceneObserver: \(note)", isPrint: isPrint)
//        updateIsEnablesProperty()
//        changeEnableMovePoint(to: !isAddMoveNode)
        sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { [self] (event) in updataScene() })
    }
    
    /// метод отмены подписки
    /// - Parameter note: сообщение к печати уведомления
    func deinitSceneObserver(note: String) {
        printMessage("Отключение Observers: \(note)", isPrint: isPrint)
//        changeEnableMovePoint(to: false)
//        distance = 0                                                                   // сбрасываем дистанцию
//        dellMoveLine()
        sceneObserver?.cancel()
    }
    
    /// Инициализация и отрисовка сцены
    /// - Parameter simd: массив координат
    func initScene(simd: simd_float4x4, isCheck: Bool) {
        printMessage("Сброс и формирование новой плоскости")
        coachingOverlay.setActive(false, animated: true)        // отключили поиск и выключили обзервер
        coachingOverlay.activatesAutomatically = false
        configureNonPlane()
        removeAllAnchors()                         // удалили все анкоры отчистили AR View
        
        drawScene(simd, isCheck: isCheck) { message in               // нарисовали новую сцену
            printMessage(message.message)
            switch message {
            case .ok(_):
                self.errorMoveNode = false                      // выключили ошибку подвижной ноды
                self.errorMovePoint = false                     // выключили ошибку подвижной точки
                self.notification = nil
                self.statusAPP = .checkSearth                                                                           // инициализация проверки поиска сцены
        //        guard self.selectedModel != nil || !self.project.isEmpty else { self.statusScene = .start; return } // если есть выбраная модель то переходим в режим добавления
                self.statusScene = .add
            default:
                self.statusAPP = .firstSearth                                                                          // инициализация нового поиска сцены
                self.configureResetTracking()                                                                          // сброс конфигурации
            }
        }
    }
    
    /// метод выбора вида прицеливания при режиме добавления
    func updataScene() {
//        distance = 0                                                            // сбрасываем дистанцию
//        dellMoveLine()                                                          // удаляем вспомогательные линии
//        guard !typeModel.isEntityModel else  { movePoint(startPoint); return }  // при статусе добавление модели - точка
//        isAddMoveNode ? moveNode(startPoint) : movePoint(startPoint)            // при статусе добавление точки - либо точка, либо линия
    }
    
    /// проверка наличия сцены
    func checkPlace(_ isCheck: Bool) {
        let query = getRaycast(startPoint)
        let status = query.status
        if statusAPP == .checkSearth {
            printMessage("Сцена определена начинает проверка корректности сцены", isPrint: isPrint)
            guard status != .no else {
                statusAPP = .isScene                                                                          // статус приложения что сцена найдена после проверки на ошибку
                initSceneObserver(note: "Проверка сцены корректная checkPlace()")                             // нет ошибки включаем общий обзервер
                return
            }
            printMessage("ОШИБКА формирования сцены - сброс", isPrint: isPrint)
            statusAPP = .firstSearth                                                                          // инициализация нового поиска сцены
            configureResetTracking()                                                                          // сброс конфигурации
        } else {
            printMessage("Сцена еще не определена", isPrint: isPrint)
            guard status == .no else { return }                                                                // если ошибка включаем поиск сцены автоматический
            deinitSceneObserver(note: "Статус поиска сцены без ошибки checkPlace()")                           // плоскость найдена отключили обзервер
            guard statusAPP != .initDB else { statusAPP = .endInit; return }                                   // если это фоновый поиск то как только нашли поменяли statusScene
            initScene(simd: query.simd, isCheck: isCheck)                                                                        // инициализация сцены
        }
    }
    
    /// обработчик луча проверка горизонтальной плоскости
    /// - Parameter p: точка луча
    /// - Returns: кортеж (ошибкаб результат)
    func getRaycast(_ p: CGPoint) -> (status: TypeRaycastError, simd: simd_float4x4) {
        let query = arView.makeRaycastQuery(from: p, allowing: .existingPlaneInfinite, alignment: .horizontal)
        guard let firstResult = query else { return (.querry, simd_float4x4()) }
        let results = arView.session.raycast(firstResult)
        guard let position = results.last?.worldTransform else { return (.result, simd_float4x4()) }
        return (.no, position)
    }
    
    /// удаляем все сущности и анкоры и снова добавляем FocusEntity
    func removeAllAnchors() {
        for anchor in arView.scene.anchors {
            if !anchor.children.isEmpty { anchor.children.removeAll() }
            arView.scene.removeAnchor(anchor)
        }
        arView.scene.anchors.removeAll()
    }
    
    
    private func changeStatusAPP() {
        printMessage("Статус приложения \(statusAPP)", isPrint: isPrint)
//        switch statusAPP {
//        case .loadView: do {}
//        case .initDB: initDB()                                                      // запуск инициализации базы данных
//        case .firstSearth: initFirstScene()                                         // запуск поиска первой сцены
//        case .endInit: if decodingURL != nil { startDeepLink() }                    // запустили ссылку если она есть
//        case .isScene:  do {}
//        case .checkSearth: initObserverRaycast(true)                                // запуск обзервера на проверку корректности определения сцены
//        }
    }
    
    /// Отработка изменения статуса сцены
    private func changeStatusScene() {
        printMessage("Изменение статуса работы сцены \(statusScene)", isPrint: isPrint)
//        switch statusScene {
//        case .start:
//            guard !(statusAPP == .initDB || statusAPP == .endInit) else { return }
//            selectedModel = nil
//            tappedEntity = nil
//            isLoadEntity = false
//            entity = nil
//            floor = nil
//            fence = nil
//            stopAudio()
//            removeGestureAllEntity()
//            addTapGestureRecognizer()
//            deinitSceneObserver(note: "Status Scene \(statusScene)")
//            if showEditProprietes { showEditProprietes.toggle() }
//        case .searth: notification = .isSearthPlane
//        case .add:
//            removeGestureAllEntity()
//            initSceneObserver(note: "Status Scene \(statusScene)")
//        case .edit:
//            switch typeModel {
//            case .fence, .wall:
//                installGesturesEntityNameID(to: fence?.nameID, scaling: false, onlyTranslation: true)
//            case .grass, .floor, .roof:
//                installGesturesEntityNameID(to: floor?.nameID, scaling: false, onlyTranslation: true)
//            default: do {}
//            }
//            createdLabelLevel()
//            updateIsEnablesProperty()
//            deinitSceneObserver(note: "Status Scene \(statusScene)")
//        case .debug:
//            if !isTest { deinitSceneObserver(note: "Status Scene \(statusScene)") }
//        }
    }
    
    /// генерация общей сцены
    /// - Parameter simd: координаты плоскости определенные Raycast
    func drawScene(_ simd: simd_float4x4, isCheck: Bool, completion: @escaping(ErrorMessage) -> Void) {

//        completion(.ok("Проверка на симуляторе"))
        
//        let movePoint = movePoint.clone(recursive: true)   // создаем клон точки прицеливания для основной сцены
//        movePoint.position = [0,0,0]
//        let pointAnchor = AnchorEntity(world: simd)
//        pointAnchor.name = NameEntitys.anchorMovePoint.name
//        pointAnchor.isEnabled = false
//        pointAnchor.addChild(movePoint)
//        
        // создаем прозрачную плоскость 10 на 10 метров средняя точка первая точка
        let color = UIColor.white
        let width: Float = 10
        let depth: Float = 10
        let mesh = MeshResource.generatePlane(width: width, depth: depth, cornerRadius: 0)
        let imageMaterial = UnlitMaterial(color: color.withAlphaComponent(0.0))
        let material = [imageMaterial]
        // создаем модель
        let sceneEntity = ModelEntity(mesh: mesh, materials: material)
        sceneEntity.name = NameEntitys.entityScene.name
        sceneEntity.position = [0,yPositionScene,0]
        sceneEntity.generateCollisionShapes(recursive: true)
        
        // создаем анкор привязку
        let sceneAnchor = AnchorEntity(plane: .horizontal)
        sceneAnchor.name = NameEntitys.anchorScene.name
        sceneAnchor.addChild(sceneEntity)
//        
//        // размещаем анкор в основном вью
//        printMessage("Название сцены \(sceneEntity.name) Название Анкора \(sceneAnchor.name)")
//        arView.scene.addAnchor(sceneAnchor)
//        arView.scene.addAnchor(pointAnchor)
//        // сохраняем в проекте матрицы анкора и общей сцены и устанавливаем признак готовности
//        let simd_scene = sceneEntity.transformMatrix(relativeTo: sceneAnchor)
//        let scale = sceneAnchor.scale(relativeTo: sceneAnchor)
          let simd_anchor = sceneAnchor.transform.matrix
//        project.simd_scene_anchor = simd_anchor
//        project.simd_scene = simd_scene
//        project.simd_scene_first = simd_scene
//        project.scale_scene = scale
//        project.scale_scene_first = scale
//        project.isReady = true
//        project.idUser = user?.id ?? ""
//        printMessage("Сохраненные координаты точки наведения Anchor :\n   x - \(simd_anchor.position().x)\n   y - \(simd_anchor.position().y)\n   z - \(simd_anchor.position().z)")
//        printMessage("Сохраненные координаты точки наведения Сцены :\n   x - \(simd_scene.position().x)\n   y - \(simd_scene.position().y)\n   z - \(simd_scene.position().z)")
        guard isCheck else {  completion(.ok("Анкор без проверок на координаты")); return }
        if simd_anchor.position().x == 0 && simd_anchor.position().y == 0 && simd_anchor.position().z == 0 {
            completion(.error("Нулевой Анкор"))
        } else {
            completion(.ok("Анкор не нулевой"))
        }
        
    }
}
