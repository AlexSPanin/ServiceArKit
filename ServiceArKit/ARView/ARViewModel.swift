//
//  ARViewModel.swift
//  ServiceArKit
//
//  Created by Александр Панин on 22.10.2024.
//

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
        case finishConfig
        case loadModel            // загрузка модели
        case finishLoadModel
        case searchScene          // поиск плоскости
        case checkScene           // проверка сцены
        case observerScene        // наблюдение за сценой
        case addModel             // установить модель
    }
    
    @Published var arView: ARView!                                                           // основное вью
    @Published var statusAPP: StatusAPP = .loadView { didSet { changeStatusAPP() }}          // статус работы приложения
    @Published var entity: ModelProperties?
    @Published var selectedModel: Model?                   // выбранная и уже загруженная модель из каталога
    
    var sceneObserver: Cancellable?                         // управление включением и выключением обзервера
    var device: MTLDevice?                                  // для инициализации metal
    var library: MTLLibrary?                                // библиотека для metal
    var surfaceShader: CustomMaterial.SurfaceShader?
    var product: Product?
    
    private let point: ModelEntity = CreatorTypicalModels.shared.createdMovePoint(size: 0.05, color: .yellow)
    private let scene: ModelEntity = CreatorTypicalModels.shared.createdPlane(size: CGSize(width: 10, height: 10),
                                                                              color: .white, opacity: 0.0)
    private let coachingOverlay = ARCoachingOverlayView()           // управление поиском плоскостей
    private let isPrint: Bool = true                                // признак печати уведомлений
    
    init() {
        printMessage("Инициализация ARViewModel", isPrint: isPrint)
        arView = ARView(frame: .zero)
        initializeMetal()
        configure()
    }
    
    private func changeStatusAPP() {
        printMessage("Статус приложения \(statusAPP)", isPrint: isPrint)
        switch statusAPP {
        case .loadModel: createdModel()                  // подготовка модели
        case .searchScene:  configureResetTracking()     // запуск поиска сцены
        case .checkScene: initObserverRaycast(true)
        case .observerScene : startObserverScene()       // запуск обзервера сцены
        case .addModel: pressAddEntity()                 // установка модели
        default : do {}
        }
    }
    
    /// конфигурируем с определением горизонтальной плоскости
    private func configure() {
        printMessage("Начало конфигурации", isPrint: isPrint)
        AuthUserManager.shared.registerAnon { _ in }
        guard Permissions.shared.checkPermissions(type: .video) else { return }
        statusAPP = .configure
        printMessage("Начало конфигурации плоскости работы")
        arView.configureResetTracking()
        addCoachingOverlay(true)
        initObserverRaycast(true)
    }
    
    /// Инициализатор обзервера луча
    private func initObserverRaycast(_ isCheck: Bool) {
        printMessage("Запус обзервера с проверкой наличия сцены \(isCheck)", isPrint: isPrint)
        sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, {(event) in self.checkPlace(isCheck) })
    }
    
    private func startObserverScene() {
        initSceneObserver(isInit: true, note: "Проверка сцены корректная Запуск подвижной точки")
    }
    
   
    
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
    
    private func pressAddEntity()  {
        guard let selectedModel = self.selectedModel, let modelEntity = selectedModel.modelEntity else { return }
        guard let type = TypeModel.allCases.first(where: {$0.label == selectedModel.card.typeModel }) else { return }
        let product = selectedModel.card
        let elements = selectedModel.card.elements
        entity = ModelProperties(idVendor: product.idVendor,
                                 idCategory: product.idCategory,
                                 idProduct: product.id,
                                 model: product.model,
                                 typeModel: type,
                                 baseY: product.basePositionY)
        entity?.parts = elements
        entity?.audio = product.audio
        entity?.modelGlb = product.modelGlb
        entity?.modelFields = product.modelFields
        arView.placeEntity(modelEntity, entity, simd: arView.getRaycast(midPoint) ) { properties in
            self.entity = properties
            self.initSceneObserver(isInit: false, note: "placeEntity")
        }
    }
    
    private func createdModel() {
        loadFilesModel(idCard: idProduct) { [self] message in
            printMessage(message.message, isPrint: isPrint)
            guard let product = product, product.typeModel == "entity" else { return }
            let model = Model(card: product)
            model.asyncLoadEntity(shader: surfaceShader) { message in
                printMessage(message.message)
                switch message {
                case .ok:
                    self.selectedModel = model
                    self.statusAPP = .finishLoadModel
                default: do {}
                }
            }
        }
    }
    
    private func loadFilesModel(idCard: String, completion: @escaping(ErrorMessage) -> Void) {
        ProductDataManager.shared.loadCard(to: idProduct) { card in
            self.product = card
            guard let file = card?.model, !file.isEmpty else { return completion(.error("ОШИБКА: в карточке не прописан файл модели")) }
            guard !FileAppManager.shared.checkExistFile(to: file, type: fileDirectory) else { return completion(.ok("ОК: файл в локальном хранилище")) }
            printMessage("Начало загрузки файла модели из сети \(file)", isPrint: self.isPrint)
            NetworkManager.shared.loadFileWriteLocal(type: .usdz, file: file, local: fileDirectory) { message in completion(message) }
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
    
}
