//
//  ARViewModel.swift
//  ServiceArKit
//
//  Created by Александр Панин on 22.10.2024.
//
import Foundation
import SwiftUI
import RealityKit
import ARKit
import MetalKit
import Combine

final class ARViewModel: ObservableObject {
    /// Статусы работы приложения
    enum StatusAPP {
        case loadView             // запуск приложения
        case configure            // стартовая конфигурация
        case finishConfig         // завершение конфигурации
        case loadCard             // загрузка продуктовой карточки
        case createdModel         // создание модели
        case finishCreatedModel   // окончание создания модели
        case loadModel            // загрузка файлов модели
        case finishLoadModel      // окончание загрузки файлов модели
        case searchScene          // поиск плоскости
        case checkScene           // проверка сцены
        case observerScene        // наблюдение за сценой
        case addModel             // установить модель
        case useModel             // использование модели
    }
    /// оси поворота
    enum AxisModel { case x, y, z }
    
    /// Составные части модели человека
    enum PartModel: String, CaseIterable {
        enum Parts { case head, body, leftHand, rightHand, leftFoot, rightFoot } // для составление групп частей модели
        case model = ""                   // для опознования основной модели
        case shoulder = "part17"          //part17- волосы
        case head = "part0"               //part0 - голова
        case eyes = "part1"               //part1 - глаза
        case neck = "part2"               //part2 - шея
        case body = "part3"               //part3 - тело
        case leftShoulder = "part5"       //part5 - плечо левое
        case rightShoulder = "part4"      //part4 - плечо правое
        case leftForearm = "part7"        //part7 - предплечье левое
        case rightForearm = "part6"       //part6 - предплечье правое
        case leftHand = "part8"           //part8- кисть левая
        case rightHand = "part9"          //part9 - кисть правая
        case pelpus = "part10"            //part10- таз
        case leftThigh = "part12"         //part12- бедро левое
        case rightThigh = "part11"        //part11- бедро правое
        case leftShin = "part14"          //part14- голень левая
        case rightShin = "part13"         //part13- голень правая
        case leftFoot = "part16"          //part16- стопа левая
        case rightFoot = "part15"         //part15- стопа правая
        
        var part: String { rawValue }
        
        func parts(_ parts: Parts ) -> [PartModel] {
            switch parts {
            case .head: return [.head, .eyes, .shoulder]                             // голова
            case .body: return [.neck, .body, .pelpus]                               // тело
            case .leftHand: return [.leftShoulder, .leftForearm, .leftHand]          // левая рука
            case .rightHand: return [.rightShoulder, .rightForearm, .rightHand]      // правая рука
            case .leftFoot: return [.leftThigh, .leftShin, .leftFoot]                // левая нога
            case .rightFoot: return [.rightThigh, .rightShin, .rightFoot]            // правая нога
            }
        }
    }
    
    /// Типы движений
    enum Movement { case no, move, rotateLeft, rotateRigth, scale }
    
    struct SimdPart {
        let part: PartModel
        let position: SIMD3<Float>
    }
    
    
    
    @Published var arView: ARView!                                                                      // основное вью
    @Published var statusAPP: StatusAPP = .loadView { didSet { changeStatusAPP() }}                     // статус работы приложения
    @Published var movementModel: Movement = .no { didSet { changeMovementModel(parts.parts(.head)) } } // отработка движения
        
    private var parts = PartModel.model                             // для выбора набора частей модели
    private var product: Product?                                   // продуктовая карточка
    private var entity: ModelProperties?                            // свойста 3Д модели
    private var selectedModel: Model?                               // выбранная и уже загруженная модель из каталога
    private var sceneObserver: Cancellable?                         // управление включением и выключением обзервера
    private var device: MTLDevice?                                  // для инициализации metal
    private var library: MTLLibrary?                                // библиотека для metal
    private var surfaceShader: CustomMaterial.SurfaceShader?        // поверхностный шрейдер для Metall
    private let coachingOverlay = ARCoachingOverlayView()           // управление поиском плоскостей
    private let isPrint: Bool = true                                // признак печати уведомлений
    
    // вспомогательные модели
    private let point: ModelEntity = CreatorTypicalModels.shared.createdMovePoint(size: 0.05, color: .yellow)
    private let scene: ModelEntity = CreatorTypicalModels.shared.createdPlane(size: CGSize(width: 10, height: 10),
                                                                              color: .white, opacity: 0.0)
    init() {
        printMessage("Инициализация ARViewModel", isPrint: isPrint)
        arView = ARView(frame: .zero)
        initializeMetal()
        configure()
    }
    
    /// Отработка типа движения
    /// - Parameter parts: массив составных частей модели для перемещения
    func changeMovementModel(_ parts: [PartModel]) {
        switch movementModel {
        case .no:
            do {}
        case .move:
            do {}
        case .rotateLeft:
            rotationModel(axis: .y, value: .pi/4, duration: 1, parts: parts)
        case .rotateRigth:
            rotationModel(axis: .y, value: -.pi/4, duration: 1, parts: parts)
        case .scale:
            do {}
        }
        
    }
    
   private func rotationModel(axis: AxisModel, value: Float, duration: TimeInterval, parts: [PartModel]) {
        guard !parts.isEmpty else { return }
        let models = parts.map { $0.part }
        let transform = Transform(pitch: axis == .x ? value : 0,
                                  yaw: axis == .y ? value : 0,
                                  roll: axis == .z ? value : 0)
        arView.getPartsEntity(entity?.nameID, parts: models) { models in
            guard !models.isEmpty else { return }
            models.forEach { model in
                model.move(to: transform, relativeTo: model, duration: duration, timingFunction: .easeInOut)
            }
        }
    }
    
//    
//    
//    
//     func turnLeft() {
//        printMessage("Поворот влево", isPrint: isPrint)
//        arView.getPartEntity(entity?.nameID, part: "part0") { model in
//            guard let model = model else { return }
//            let transform = Transform(pitch: 0, yaw: .pi/8, roll: 0)
//            model.move(to: transform, relativeTo: model, duration: 4, timingFunction: .easeInOut)
//        }
//    }
//    
//    func turnRigth() {
//       printMessage("Поворот влево", isPrint: isPrint)
//       arView.getPartEntity(entity?.nameID, part: "part0") { model in
//           guard let model = model else { return }
//           let transform = Transform(pitch: 0, yaw: -.pi/8, roll: 0)
//           model.move(to: transform, relativeTo: model, duration: 4, timingFunction: .easeInOut)
//       }
//      
//   }
    
//    let moveDown = SCNAction.move(by: SCNVector3(0, -0.1, 0), duration: 1)
//           let moveUp = SCNAction.move(by: SCNVector3(0,0.1,0), duration: 1)
//           let waitAction = SCNAction.wait(duration: 0.25)
//           let hoverSequence = SCNAction.sequence([moveUp,waitAction,moveDown])
//           let loopSequence = SCNAction.repeatForever(hoverSequence)
//           node2Animate.runAction(loopSequence)
//
//           self.sceneView.scene.rootNode.addChildNode(node2Animate)
    
    /// Отработка этапов приложения
    private func changeStatusAPP() {
        printMessage("Статус приложения \(statusAPP)", isPrint: isPrint)
        switch statusAPP {
        case .loadCard: loadProdactCard(idCard: idProduct)  // подготовка модели
        case .createdModel: createdModel()
        case .finishCreatedModel: statusAPP = .loadModel
        case .loadModel:
            Task {
                await loadModelEntity { message in
                    printMessage(message.message, isPrint: self.isPrint)
                    switch message {
                    case .error(_):
                        self.statusAPP = .createdModel
                    default:
                        self.statusAPP = .finishLoadModel
                    }
                }
            }
        case .finishLoadModel: statusAPP = .searchScene
        case .searchScene:  configureResetTracking()        // запуск поиска сцены
        case .checkScene: initObserverRaycast(true)
        case .observerScene : startObserverScene()         // запуск обзервера сцены
        case .addModel: pressAddEntity()                   // установка модели
        default : do {}
        }
    }
    
    /// конфигурируем с определением горизонтальной плоскости
    private func configure() {
        printMessage("Начало конфигурации", isPrint: isPrint)
        AuthUserManager.shared.registerAnon { _ in }
        FileAppManager.shared.clearLocal(fileDirectory)
        guard Permissions.shared.checkPermissions(type: .video) else { return }
        statusAPP = .configure
        printMessage("Начало конфигурации плоскости работы")
        arView.configureResetTracking()
        addCoachingOverlay(true)
        initObserverRaycast(true)
    }
    
    /// проверка наличия сцены
    private func checkPlace(_ isCheck: Bool) {
        let simd = arView.getRaycast(midPoint)
        switch statusAPP {
        case .searchScene, .configure:
            guard let simd = simd, simd != simd_float4x4() else { return } // если ошибка включаем продолжаем поиск сцены
            initScene(simd: simd, isCheck: isCheck)                        // инициализация сцены
        case .checkScene:
            printMessage("Сцена определена начинает проверка корректности сцены", isPrint: isPrint)
            statusAPP = (simd == nil || simd == simd_float4x4() ) ? .searchScene : .observerScene
        default: do {}
        }
    }
    
    /// Инициализация и отрисовка сцены
    /// - Parameter simd: массив координат
    private func initScene(simd: simd_float4x4, isCheck: Bool) {
        initSceneObserver(isInit: false, note: "Определена плоскость без проверки ошибки. Останавливаем Обзервер")
        printMessage("Сброс и формирование новой плоскости Сцены", isPrint: isPrint)
        closeCoachingOverlay()
        arView.configureNonPlane()
        arView.removeAllAnchors()                                   // удалили все анкоры отчистили AR View
        arView.drawScene(simd, point: point, scene: scene, isCheck: isCheck) { message in       // нарисовали новую сцену
            printMessage(message.message)
            switch message {
            case .ok(_):
                self.statusAPP = self.statusAPP == .configure ? .finishConfig : .checkScene  // инициализация проверку сцены
            default:
                self.statusAPP = .searchScene                       // инициализация нового поиска сцены
            }
        }
    }
    
    /// установка модели на плоскость
    private func pressAddEntity()  {
        guard let selectedModel = self.selectedModel, let modelEntity = selectedModel.modelEntity else { return }
        entity = ModelProperties(product: selectedModel.card)
        arView.placeEntity(modelEntity, entity, simd: arView.getRaycast(midPoint) ) { properties in
            self.entity = properties
            self.statusAPP = .useModel
            self.initSceneObserver(isInit: false, note: "placeEntity")
        }
    }
    
    /// загрузка файлов и создание модели
    /// - Parameter completion: системное сообщение
    private func loadModelEntity(completion: @escaping (ErrorMessage) -> Void ) async  {
        guard let model = selectedModel else { return completion(.error("модель не определена")) }
        model.asyncLoadModelEntity(shader: self.surfaceShader) { message in
            printMessage(message.message)
            switch message {
            case .ok:
                self.selectedModel = model
                completion(.ok("модель определена"))
            default: completion(message)
            }
        }
    }
    
    /// инициализация модели из карточки продукта
    private func createdModel() {
        guard let product = product, product.typeModel == "entity" else { return }
        let model = Model(card: product)
        model.initModel { model in
            self.selectedModel = model
            self.statusAPP = .finishCreatedModel
        }
    }
    
    /// загрузка карточки продукта
    /// - Parameter idCard: идентификатор карточки продукта из БД
    private func loadProdactCard(idCard: String) {
        ProductDataManager.shared.loadCard(to: idProduct) { card in
            self.product = card
            self.statusAPP = .createdModel
        }
    }
    
    /// Инициализация библиотеки metal
    private func initializeMetal() {
        printMessage("Начало инициализации библиотеки Metal")
        guard let maybeDevice = MTLCreateSystemDefaultDevice() else { fatalError("Error creating default metal device.") }
        device = maybeDevice
        guard let maybeLibrary = maybeDevice.makeDefaultLibrary() else { fatalError("Error creating default metal library") }
        library = maybeLibrary
        guard let library = library else { fatalError("фатальная ошибка подготовки metal device.") }
        surfaceShader = CustomMaterial.SurfaceShader(named: "DissolveSurfaceShader", in: library)
        printMessage("Библиотека Metal инициализирована")
    }
    
    /// конфигурируем со сбросом всех заранее найденных плоскостей и с определением горизонтальной плоскости
    private func configureResetTracking() {
        printMessage("Сброс конфигурации плоскости работы")
        arView.configureResetTracking()
        addCoachingOverlay(true)
        initObserverRaycast(true)
    }
    
    /// Запуск поиска плоскости в ARView
    /// - Parameter isAnimation: признак анимированного поиска
    private func addCoachingOverlay(_ isAnimation: Bool) {
        printMessage("Запуск поиска горизонтальной плоскости")
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.activatesAutomatically = true                        // включили поиск плоскостей
        coachingOverlay.setActive(true, animated: isAnimation)
        arView.addSubview(coachingOverlay)
    }
    
    /// Выключаем поиск Плоскости в ArView
    private func closeCoachingOverlay() {
        coachingOverlay.setActive(false, animated: true)            // отключили поиск и выключили обзервер
        coachingOverlay.activatesAutomatically = false
    }
    
    /// Инициализатор обзервера луча
    private func initObserverRaycast(_ isCheck: Bool) {
        printMessage("Запус обзервера с проверкой наличия сцены \(isCheck)", isPrint: isPrint)
        sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, {(event) in self.checkPlace(isCheck) })
    }
    
    /// Включение обзервера с подижной точкой
    private func startObserverScene() {
        initSceneObserver(isInit: true, note: "Проверка сцены корректная Запуск подвижной точки")
    }
    
    /// управление работой обзервера
    /// - Parameters:
    ///   - isInit: true включение обзервера
    ///   - note: системное сообщение для печати
    private func initSceneObserver(isInit: Bool, note: String) {
        if isInit {
            printMessage("Инициализация SceneObserver: \(note)")
            arView.enableMovePoint(true)
            sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { [self] (event) in arView.movePoint() })
        } else {
            printMessage("Отключение Observers: \(note)")
            arView.enableMovePoint(false)
            sceneObserver?.cancel()
        }
    }
}
