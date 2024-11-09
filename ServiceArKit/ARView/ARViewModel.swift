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

    enum TypeRaycastError {
        case no, querry, result
    }
    
    /// Статусы работы приложения
    enum StatusAPP {
        case loadView             // запуск приложения
        case startDB              // инициализация базы данных
        case finishDB             // окончание инициализации после фонового определения плоскости
        case startSearth          // запуск фонового поиска плоскостей
        case checkSearth          // проверка корректности поиска сцены
        case isScene              // плоскость найдена
    }
    
    /// Статусы работы приложения при отрисовке
    enum StatusScene: Codable {
        case start                // режим работы ARView без обзервера
        case searth               // режим ожидания поиска плоскости
        case add                  // режим добавления
        case edit                 // режим редактирования
        case debug                // режим отладки
    }
    
    @Published var arView: ARView!                                                           // основное вью
    @Published var notification: NotificationAlert?                                          // окна уведомления
    @Published var statusAPP: StatusAPP = .loadView { didSet { changeStatusAPP() }}          // статус работы приложения
    @Published var statusScene: StatusScene = .start { didSet { changeStatusScene()  } }          // статус сцены редактиование, добавление
    //MARK: - публикация ошибок поиска плоскости или точки
    @Published var errorMovePoint: Bool = false                                              // ошибка отрисовки подвижной точки
    @Published var errorMoveNode: Bool = false                                               // ошибка отрисовки подвижной ноды
    @Published var isLoad: Bool = false                                                      // отработка загразки файла модели
    //MARK: - выбранные, загруженные
//    @Published var selectedModel: Model?                                                   // выбранная и уже загруженная модель из каталога
    var sceneObserver: Cancellable?                                                          // управление включением и выключением обзервера
    var isSupportSceneReconstruction: Bool = false                                           // признак реконструкции сцены лидаром
    let coachingOverlay = ARCoachingOverlayView()                                            // управление поиском плоскостей
    var surfaceShader: CustomMaterial.SurfaceShader?
    
    @Published var entity: ModelProperties? { didSet {
        //updateIsEnablesProperty()
    } }         // модели
    //MARK: - выбранные, загруженные
    @Published var selectedModel: Model?                                                // выбранная и уже загруженная модель из каталога
    @Published var loadModel: Model? { didSet {
     //   selectingModel()
    } }                    // для старта загрузки моделей
    
    var product: Product?
    var constant: ConstantSetting?
    
    private let isPrint: Bool = true                                                        // признак печати уведомлений
    
    init() {
        printMessage("Инициализация ARViewModel", isPrint: isPrint)
        arView = ARView(frame: .zero)
    }
    
    private func loadFilesModel(idCard: String, completion: @escaping(ErrorMessage) -> Void) {
        isLoad = true
        ProductDataManager.shared.loadCard(to: idProduct) { card in
            self.product = card
            guard let file = card?.model, !file.isEmpty else { return completion(.error("ОШИБКА: в карточке не прописан файл модели")) }
            guard !FileAppManager.shared.checkExistFile(to: file, type: fileDirectory) else { return completion(.ok("ОК: файл в локальном хранилище")) }
            printMessage("Начало загрузки файла модели из сети \(file)", isPrint: self.isPrint)
            NetworkManager.shared.loadFileWriteLocal(type: .usdz, file: file, local: fileDirectory) { error in completion(error) }
        }
    }
    
    func createdModel() {
        loadFilesModel(idCard: idProduct) { [self] error in
            printMessage(error.message, isPrint: isPrint)
            isLoad = false
            guard let product = product, let constant = constant else { return }
            let model = Model(card: product)
            selectedModel = model
            loadModel = model
            pressAddEntity(constant.midPoint)
        }
    }
    
    public func pressAddEntity(_ p: CGPoint)  {
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
  //      typeModel = type
        entity?.parts = elements
        entity?.audio = product.audio
        entity?.modelGlb = product.modelGlb
        entity?.modelFields = product.modelFields
        
        let query = getRaycast(p)
        deinitSceneObserver(note: "placeEntity")
        guard query.status == .no else { return }
        arView.placeEntity(modelEntity, entity, position: query.simd.position()) { properties in
            self.entity = properties
            //     startAnimation()
        }
   //     placeEntity(modelEntity, point: p, baseY: product.basePositionY )

    }
    
    /// конфигурируем с определением горизонтальной плоскости
    func configure() {
        AuthUserManager.shared.registerAnon { _ in }
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
        addCoachingOverlay(true)
  //      initObserverRaycast(true)
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
        arView.changeEnableMovePoint(to: true)
        sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { [self] (event) in updataScene() })
    }
    
    /// метод отмены подписки
    /// - Parameter note: сообщение к печати уведомления
    func deinitSceneObserver(note: String) {
        printMessage("Отключение Observers: \(note)", isPrint: isPrint)
        arView.changeEnableMovePoint(to: false)
//        distance = 0                                                                   // сбрасываем дистанцию
//        dellMoveLine()
        sceneObserver?.cancel()
    }
    
    /// Инициализация и отрисовка сцены
    /// - Parameter simd: массив координат
    func initScene(simd: simd_float4x4, isCheck: Bool) {
        printMessage("Сброс и формирование новой плоскости", isPrint: isPrint)
        coachingOverlay.setActive(false, animated: true)            // отключили поиск и выключили обзервер
        coachingOverlay.activatesAutomatically = false
        configureNonPlane()
        arView.removeAllAnchors()                                          // удалили все анкоры отчистили AR View
        
        arView.drawScene(simd, isCheck: isCheck) { message in               // нарисовали новую сцену
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
                self.statusAPP = .startSearth                                                                          // инициализация нового поиска сцены
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
        guard let midPoint = constant?.midPoint else { return }
        let query = getRaycast(midPoint)
        let status = query.status
        if statusAPP == .checkSearth {
            printMessage("Сцена определена начинает проверка корректности сцены", isPrint: isPrint)
            guard status != .no else {
                statusAPP = .isScene                                                                          // статус приложения что сцена найдена после проверки на ошибку
                initSceneObserver(note: "Проверка сцены корректная checkPlace()")                             // нет ошибки включаем общий обзервер
                return
            }
            printMessage("ОШИБКА формирования сцены - сброс", isPrint: isPrint)
            statusAPP = .startSearth                                                                          // инициализация нового поиска сцены
            configureResetTracking()                                                                          // сброс конфигурации
        } else {
            printMessage("Сцена еще не определена", isPrint: isPrint)
            guard status == .no else { return }                                                                // если ошибка включаем поиск сцены автоматический
            deinitSceneObserver(note: "Статус поиска сцены без ошибки checkPlace()")                           // плоскость найдена отключили обзервер
            guard statusAPP != .startDB else { statusAPP = .finishDB; return }                                   // если это фоновый поиск то как только нашли поменяли statusScene
            initScene(simd: query.simd, isCheck: isCheck)                                                      // инициализация сцены
        }
    }
    
    /// обработчик луча проверка горизонтальной плоскости
    /// - Parameter p: точка луча
    /// - Returns: кортеж (ошибкаб результат)
    private func getRaycast(_ p: CGPoint) -> (status: TypeRaycastError, simd: simd_float4x4) {
        let query = arView.makeRaycastQuery(from: p, allowing: .existingPlaneInfinite, alignment: .horizontal)
        guard let firstResult = query else { return (.querry, simd_float4x4()) }
        let results = arView.session.raycast(firstResult)
        guard let position = results.last?.worldTransform else { return (.result, simd_float4x4()) }
        return (.no, position)
    }
    
   
    
    
    private func changeStatusAPP() {
        printMessage("Статус приложения \(statusAPP)", isPrint: isPrint)
        switch statusAPP {
        case .startDB: initDB()                                                      // запуск инициализации базы данных
        case .startSearth: initFirstScene()                                         // запуск поиска первой сцены
 //       case .endInit: if decodingURL != nil { startDeepLink() }                    // запустили ссылку если она есть
        case .checkSearth: initObserverRaycast(true)                                // запуск обзервера на проверку корректности определения сцены
        default : do {}
        }
    }
    
    /// Анимированный поиск плоскости с установкой сцены
    private func initFirstScene() {
        printMessage("Инициализация первого поиска сцены")
        configureResetTracking()                                       // первый и единственный раз определяем плоскость
 //       addTapGestureRecognizer()                                      // добавление отработки жестов на экране
 //       updateIsEnablesProperty()                                      // обнавляем наличие кнопки для редактирования свойств
    }
    
    /// Получение базы данных и инициализация дополнительных библиотек
    private func initDB() {
        guard Permissions.shared.checkPermissions(type: .video) else { notification = .deniedCamera; return  }
 //       initializeMetal()
        fetchDataBase()
        
    }
    
    
    
    /// загрузка основных массивов и ключей
    private func fetchDataBase() {
//        storage.load(type: .user, model: UserAPP.self) { user in self.user = user }
//        checkUserTypeLinks()                                                                  // проверили откуда пришел пользователь
//        activeGroups = db.groupCategories.compactMap({$0.0})
//        modelsFloor = db.getModelsType(type: .floor)?.compactMap( {$0.card.collection}) ?? []
//        modelsRoof = db.getModelsType(type: .roof)?.compactMap( {$0.card.collection} ) ?? []
//        updateIsEnablesProperty()                                                             // обнавляем наличие кнопки для редактирования свойств
//        printMessage("Базы данных сформированы Входной URL \(String(describing: openURL))")
//        guard openURL != nil else {  showCatalog = true; return }
//        printMessage("Ожидаем открытия ссылки \(user?.typeLinks ?? "нет ссылки")")
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
}
