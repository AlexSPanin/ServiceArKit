//
//  ProductCollection.swift
//  AdminServiceAR
//
//  Created by Александр Панин on 23.02.2023.
//

import Foundation

/// Модель карточки товара
struct Product: Codable {
    // Блок к начальной загрузке
    var id: String = UUID().uuidString                                  // id карточки товара
    var isActive: Bool = false                                          // признак активности/показа карточки товара
    var showHeart: Bool = false                                         // признак любимой карточки используется локально
    
    // Блок редактирования
    var idUser: String = ""                                             // id пользователя кто создал карточку или изменил ее
    var date: String = Date().timeStamp()                               // дата создания или изменения
    var countUse: Int = 0                                               // количество использований карточки товара в заказах и проектах для контроля удаления и деактивации
    
    // Блок ID
    var idVendor: String = ""                                           // id производителя товара
    var idCategory: String = ""                                         // id тованой категории к которой относиться карточка товара
    var idGroups: [String] = []                                         // массив id товарных групп к которым относится карточка товара
    var idProprietes: [String] = []                                     // массив id товарных свойств для быстрой фильтрации которые относятся к карточке товара
    var idParts: String = ""                                            // system для отрисованных продуктов id типового набора составных частей к удалению

    var isLayers: Bool = false                                          // признак что модель товара имееет цветовые слои

    var sort: String = ""                                               // индекс сортировки
    var typeUnit: String = ""                                           // тип единиц измерений шт. / м2 / м/п
  
    var name: [String: String] = [:]                                    // краткое наименование товара [ тип языка : значение ]
    var label: [String: String] = [:]                                   // наименование при отображении карточки товара [ тип языка : значение ]
    var description: [String: String] = [:]                             // описание товара [ тип языка : значение ]
    var specification: [String: [String : String]] = [:]                // спецификация на товар [ тип поля : [ тип языка : значение ]] тип поля: артикул, вес, размер итд
                                                                        // спецификация Этажность на товар Дом [ тип поля "home" : [ наименование : значение ]] тип поля: артикул, вес, размер итд
    var typeModel: String = "entity"                                    // тип используемой модели (3Д, пол, ограждения итд)
    var model: String = ""                                              // имя файла модели для IOS
    var modelGlb: String = ""                                           // имя файла модели для Android
    
    // Блок позиционирования на сцене
    var scaleCompensation: Float = 1                                    // компенсация увеличения (лучше деактивировать)
    var basePositionY: Float = 0                                        // позиция по высоте по умолчанию где 1 - это 1 метр вверх
    
    // Блок рейтинг
    var rating: String = ""                                             // значение рейтинга
    var count: Int = 0                                                  // кол-во оценок
    var sum: Int = 0                                                    // сумма оценок
   
    // Блок цен и продвижения
    var typeAction: String = ""                                         // тип акции новинка, распродажа, акция
    var price: Float = 0                                                // базовая цена округление до 1 руб.
    var actionPrice: Float = 0                                          // акционная цена
    var actionRate: Float = 0                                           // процент скидки
    
    // Блок изображений
    var imageThumbnail: String = ""                                     // имя файла основной картинки продукта
    var imagesProduct: [String] = []                                    // массив имен файлов дополнительных картинок
    
    // Блок анимации
    var isAnimation: Bool = false                                       // признак наличия анимированной модели
    
    // Блок аудио
    var isAudio: Bool = false                                           // признак наличия аудио файлов к данной карточке
    var audio: [String] = []                                            // массив имен аудиофайлов
    
    //MARK: новые поля с переносом в новую модель
    var modelFields: [String: String] = ["glb" : "",
                                         "scale" : String(Float(1.0)),
                                         "baseY" : String(Float(0.0))]   // словарь для полей модели для новой структуры
    var elements: [ProductPart] = []                                     // массив карточек составных частей товара
    var filters: Filters = Filters()                                     // модель для фильтрации по товару
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case isActive = "isActive"
        case showHeart = "showHeart"
        
        case idUser = "idUser"
        case date = "date"
        case countUse = "countUse"
        
        case idVendor = "idVendor"
        case idCategory = "idCategory"
        case idGroups = "idGroups"
        case idProprietes = "idProprietes"
        case idParts = "idParts"
        
        case isLayers = "isLayers"
       
        case sort = "sort"
        case typeUnit = "typeUnit"
        
        case name = "name"
        case label = "label"
        case description = "description"
        case specification = "specification"
        
        case typeModel = "typeModel"
        case model = "model"
        case modelGlb = "modelGlb"
        
        case scaleCompensation = "scaleCompensation"
        case basePositionY = "basePositionY"
        
        case rating = "rating"
        case count = "count"
        case sum = "sum"
        
        case typeAction = "typeAction"
        case price = "price"
        case actionPrice = "actionPrice"
        case actionRate = "actionRate"
        
        case imageThumbnail = "imageThumbnail"
        case imagesProduct = "imagesProduct"
        
        case isAnimation = "isAnimation"
        
        case isAudio = "isAudio"
        case audio = "audio"
        
        case modelFields = "modelFields"
        case elements = "elements"
        case filters = "filters"
    }
    
    init() {}
    
    init(json:[String: Any]) {
        self.id = json["id"] as? String ?? ""
        self.date = json["date"] as? String ?? ""
        self.idUser = json["idUser"] as? String ?? ""
        self.idVendor = json["idVendor"] as? String ?? ""
        self.idCategory = json["idCategory"] as? String ?? ""
        self.idGroups = json["idGroups"] as? [String] ?? []
        self.idProprietes = json["idProprietes"] as? [String] ?? []
        self.idParts = json["idParts"] as? String ?? ""
        
        self.isActive = json["isActive"] as? Bool ?? false
        self.isLayers = json["isLayers"] as? Bool ?? false
        self.isAudio = json["isAudio"] as? Bool ?? false
        self.isAnimation = json["isAnimation"] as? Bool ?? false
        self.showHeart = json["showHeart"] as? Bool ?? false
        
        self.countUse = json["countUse"] as? Int ?? 0
        self.sort = json["sort"] as? String ?? ""
        self.typeUnit = json["typeUnit"] as? String ?? ""
        
        self.name = json["name"] as? [String: String] ?? [:]
        self.label = json["label"] as? [String: String] ?? [:]
        self.description = json["description"] as? [String: String] ?? [:]
        self.specification = json["specification"] as? [String:[String: String]] ?? [:]
        
        self.typeModel = json["typeModel"] as? String ?? "entity"
        self.model = json["model"] as? String ?? ""
        self.modelGlb = json["modelGlb"] as? String ?? ""
        self.scaleCompensation = json["scaleCompensation"] as? Float ?? 1
        self.basePositionY = json["basePositionY"] as? Float ?? 0
        
        self.modelFields = json["modelFields"] as? [String:String] ?? [ "glb" : "",
                                                                        "scale" : String(Float(1.0)),
                                                                        "baseY" : String(Float(0.0))]
        
        self.rating = json["rating"] as? String ?? ""
        self.count = json["count"] as? Int ?? 0
        self.sum = json["sum"] as? Int ?? 0
        
        self.typeAction = json["typeAction"] as? String ?? ""
        self.price = json["price"] as? Float ?? 0
        self.actionPrice = json["actionPrice"] as? Float ?? 0
        self.actionRate = json["actionRate"] as? Float ?? 0
        
        self.imageThumbnail = json["imageThumbnail"] as? String ?? ""
        self.imagesProduct = json["imagesProduct"] as? [String] ?? []
        self.audio = json["audio"] as? [String] ?? []
        self.elements = json["elements"] as? [ProductPart] ?? []
        self.filters = json["filters"] as? Filters ?? Filters()
    }
    
    public init(from decoder: Decoder) throws {
        let isPrint: Bool = true
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.id = try container.decode(String.self, forKey: .id)
        } catch {
            printMessage("Product Ошибка декодирования поля Id", isPrint: isPrint)
            self.id = ""
        }
        do {
            self.isActive = try container.decode(Bool.self, forKey: .isActive)
        } catch {
            printMessage("Product Ошибка декодирования поля isActive", isPrint: isPrint)
            self.isActive = false
        }
        do {
            self.showHeart = try container.decode(Bool.self, forKey: .showHeart)
        } catch {
            printMessage("Product Ошибка декодирования поля showHeart", isPrint: isPrint)
            self.showHeart = false
        }
        //-----------------------
        do {
            self.idUser = try container.decode(String.self, forKey: .idUser)
        } catch {
            printMessage("Product Ошибка декодирования поля IdUser", isPrint: isPrint)
            self.idUser = ""
        }
        do {
            self.date = try container.decode(String.self, forKey: .date)
        } catch {
            printMessage("Product Ошибка декодирования поля Date", isPrint: isPrint)
            self.date = ""
        }
        do {
            self.countUse = try container.decode(Int.self, forKey: .countUse)
        } catch {
            printMessage("Product Ошибка декодирования поля countUse", isPrint: isPrint)
            self.countUse = 0
        }
        //-------------------------
        do {
            self.idVendor = try container.decode(String.self, forKey: .idVendor)
        } catch {
            printMessage("Product Ошибка декодирования поля idVendor", isPrint: isPrint)
            self.idVendor = ""
        }
        do {
            self.idCategory = try container.decode(String.self, forKey: .idCategory)
        } catch {
            printMessage("Product Ошибка декодирования поля idCategory", isPrint: isPrint)
            self.idCategory = ""
        }
        do {
            self.idGroups = try container.decode([String].self, forKey: .idGroups)
        } catch {
            printMessage("Product Ошибка декодирования поля idGroups", isPrint: isPrint)
            self.idGroups = []
        }
        do {
            self.idProprietes = try container.decode([String].self, forKey: .idProprietes)
        } catch {
            printMessage("Product Ошибка декодирования поля idProprietes", isPrint: isPrint)
            self.idProprietes = []
        }
        do {
            self.idParts = try container.decode(String.self, forKey: .idParts)
        } catch {
            printMessage("Product Ошибка декодирования поля idParts", isPrint: isPrint)
            self.idParts = ""
        }
        //-------------------------
        do {
            self.isLayers = try container.decode(Bool.self, forKey: .isLayers)
        } catch {
            printMessage("Product Ошибка декодирования поля isLayers", isPrint: isPrint)
            self.isLayers = false
        }
        //------------------------
        do {
            self.sort = try container.decode(String.self, forKey: .sort)
        } catch {
            printMessage("Product Ошибка декодирования поля Sort", isPrint: isPrint)
            self.sort = ""
        }
        do {
            self.typeUnit = try container.decode(String.self, forKey: .typeUnit)
        } catch {
            printMessage("Product Ошибка декодирования поля typeUnit", isPrint: isPrint)
            self.typeUnit = ""
        }
        //-------------------------
        do {
            self.name = try container.decode([String: String].self, forKey: .name)
        } catch {
            printMessage("Product Ошибка декодирования поля Name", isPrint: isPrint)
            self.name = [:]
        }
        do {
            self.label = try container.decode([String:String].self, forKey: .label)
        } catch {
            printMessage("Product Ошибка декодирования поля Label", isPrint: isPrint)
            self.label = [:]
        }
        do {
            self.description = try container.decode([String:String].self, forKey: .description)
        } catch {
            printMessage("Product Ошибка декодирования поля Description", isPrint: isPrint)
            self.description = [:]
        }
        do {
            self.specification = try container.decode([String: [String : String]].self, forKey: .specification)
        } catch {
            printMessage("Product Ошибка декодирования поля Specification", isPrint: isPrint)
            self.specification = [:]
        }
        //--------------------------
        do {
            self.typeModel = try container.decode(String.self, forKey: .typeModel)
        } catch {
            printMessage("Product Ошибка декодирования поля typeModel", isPrint: isPrint)
            self.typeModel = ""
        }
        do {
            self.model = try container.decode(String.self, forKey: .model)
        } catch {
            printMessage("Product Ошибка декодирования поля model", isPrint: isPrint)
            self.model = ""
        }
        do {
            self.modelGlb = try container.decode(String.self, forKey: .modelGlb)
        } catch {
            printMessage("Product Ошибка декодирования поля modelGlb", isPrint: isPrint)
            self.modelGlb = ""
        }
        //-----------------------------
        do {
            self.scaleCompensation = try container.decode(Float.self, forKey: .scaleCompensation)
        } catch {
            printMessage("Product Ошибка декодирования поля scaleCompensation", isPrint: isPrint)
            self.scaleCompensation = 1.0
        }
        do {
            self.basePositionY = try container.decode(Float.self, forKey: .basePositionY)
        } catch {
            printMessage("Product Ошибка декодирования поля basePositionY", isPrint: isPrint)
            self.basePositionY = 0.0
        }
        //----------------------------
        do {
            self.rating = try container.decode(String.self, forKey: .rating)
        } catch {
            printMessage("Product Ошибка декодирования поля rating", isPrint: isPrint)
            self.rating = ""
        }
        do {
            self.count = try container.decode(Int.self, forKey: .count)
        } catch {
            printMessage("Product Ошибка декодирования поля count", isPrint: isPrint)
            self.count = 0
        }
        do {
            self.sum = try container.decode(Int.self, forKey: .sum)
        } catch {
            printMessage("Product Ошибка декодирования поля sum", isPrint: isPrint)
            self.sum = 0
        }
        //------------------------------
        do {
            self.typeAction = try container.decode(String.self, forKey: .typeAction)
        } catch {
            printMessage("Product Ошибка декодирования поля typeAction", isPrint: isPrint)
            self.typeAction = ""
        }
        do {
            self.price = try container.decode(Float.self, forKey: .price)
        } catch {
            printMessage("Product Ошибка декодирования поля price", isPrint: isPrint)
            self.price = 0
        }
        do {
            self.actionPrice = try container.decode(Float.self, forKey: .actionPrice)
        } catch {
            printMessage("Product Ошибка декодирования поля actionPrice", isPrint: isPrint)
            self.actionPrice = 0
        }
        do {
            self.actionRate = try container.decode(Float.self, forKey: .actionRate)
        } catch {
            printMessage("Product Ошибка декодирования поля actionRate", isPrint: isPrint)
            self.actionRate = 0
        }
        //-----------------------------
        do {
            self.imageThumbnail = try container.decode(String.self, forKey: .imageThumbnail)
        } catch {
            printMessage("Product Ошибка декодирования поля imageThumbnail", isPrint: isPrint)
            self.imageThumbnail = ""
        }
        do {
            self.imagesProduct = try container.decode([String].self, forKey: .imagesProduct)
        } catch {
            printMessage("Product Ошибка декодирования поля imagesProduct", isPrint: isPrint)
            self.imagesProduct = []
        }
        //----------------------------
        do {
            self.isAnimation = try container.decode(Bool.self, forKey: .isAnimation)
        } catch {
            printMessage("Product Ошибка декодирования поля isAnimation", isPrint: isPrint)
            self.isAnimation = false
        }
        //------------------------
        do {
            self.isAudio = try container.decode(Bool.self, forKey: .isAudio)
        } catch {
            printMessage("Product Ошибка декодирования поля isAudio", isPrint: isPrint)
            self.isAudio = false
        }
        do {
            self.audio = try container.decode([String].self, forKey: .audio)
        } catch {
            printMessage("Product Ошибка декодирования поля audio", isPrint: isPrint)
            self.audio = []
        }
        //------------------------
        do {
            self.modelFields = try container.decode([String: String].self, forKey: .modelFields)
        } catch {
            printMessage("Product Ошибка декодирования поля modelFields", isPrint: isPrint)
            self.modelFields = ["glb" : "",
                                "scale" : String(Float(1.0)),
                                "baseY" : String(Float(0.0))]
        }
        do {
            self.elements = try container.decode([ProductPart].self, forKey: .elements)
        } catch {
            printMessage("Product Ошибка декодирования поля elements", isPrint: isPrint)
            self.elements = []
        }
        do {
            self.filters = try container.decode(Filters.self, forKey: .filters)
        } catch {
            printMessage("Product Ошибка декодирования поля filters", isPrint: isPrint)
            self.filters = Filters()
        }
    }
    
    /// готовить массив для записи
    /// - Returns: массив для записи JSON
    func getJson() -> [String: Any] {
        var data = [String: Any]()
        if !self.id.isEmpty {data["id"] = self.id }
        if !self.date.isEmpty {data["date"] = self.date }
        if !self.idUser.isEmpty {data["idUser"] = self.idUser }
        if !self.idVendor.isEmpty {data["idVendor"] = self.idVendor}
        if !self.idCategory.isEmpty {data["idCategory"] = self.idCategory }
        if !self.idGroups.isEmpty {data["idGroups"] = self.idGroups }
        if !self.idProprietes.isEmpty {data["idProprietes"] = self.idProprietes }
        if !self.idParts.isEmpty {data["idParts"] = self.idParts }
        
        data["isActive"] = self.isActive
        data["isLayers"] = self.isLayers
        data["isAudio"] = self.isAudio
        data["isAnimation"] = self.isAnimation

        data["showHeart"] = self.showHeart
        data["countUse"] = self.countUse
        if !self.sort.isEmpty {data["sort"] = self.sort }
        if !self.typeUnit.isEmpty {data["typeUnit"] = self.typeUnit }
        if !self.typeModel.isEmpty {data["typeModel"] = self.typeModel }
        if !self.typeAction.isEmpty {data["typeAction"] = self.typeAction }
        
        if !self.name.isEmpty {data["name"] = self.name }
        if !self.label.isEmpty {data["label"] = self.label }
        if !self.description.isEmpty {data["description"] = self.description }
        if !self.specification.isEmpty {data["specification"] = self.specification }
        if !self.modelFields.isEmpty {data["modelFields"] = self.modelFields }
        
        if !self.model.isEmpty {data["model"] = self.model }
        if !self.modelGlb.isEmpty {data["modelGlb"] = self.modelGlb }
        
        data["scaleCompensation"] = self.scaleCompensation
        data["basePositionY"] = self.basePositionY
        
        data["count"] = self.count
        data["sum"] = self.sum
        if !self.rating.isEmpty {data["rating"] = self.rating }
       
        data["price"] = self.price
        data["actionPrice"] = self.actionPrice
        data["actionRate"] = self.actionRate
        
        if !self.imageThumbnail.isEmpty {data["imageThumbnail"] = self.imageThumbnail }
        if !self.imagesProduct.isEmpty {data["imagesProduct"] = self.imagesProduct }
        if !self.audio.isEmpty {data["audio"] = self.audio }
        if !self.elements.isEmpty { data["elements"] = self.elements.map { $0.getJson() } }
        
        data["filters"] = self.filters.getJson()
        return data as [String : Any]
    }
}

/// Модель карточки составной части модели
struct ProductPart: Codable {
    var id: String = UUID().uuidString                                  // id карточки элемента модели товара
    var date: String = Date().timeStamp()                               // дата создания или изменения
    var idUser: String = ""                                             // id пользователя кто создал карточку или изменил ее
    var idProduct: String = ""                                          // id карточки товара
    var idPart: String = ""                                             // id карточки элемента из типового набора составных частей
    var idColors: String = ""                                           // id цветовой коллекции или текстурной коллекции
    var namePart: String = ""                                           // имя карточки элемента из типового набора составных частей
    
    var sort: String = ""                                               // индекс сортировки
    var name: [String: String] = [:]                                    // краткое наименование товара [ тип языка : значение ]
    var label: [String: String] = [:]                                   // наименование при отображении элемента в карточках [ тип языка : значение ] если пустое то name
    
    var extraCharge: [String: Float] = [:]                              // словарь изменения цены от выбранного цвета/текстуры [ id цвета/текстуры : значение ]
    
    var select: String = ""                                             // id текущего выбранного цвета/текстуры
    var start: String = ""                                              // id начального цвета/текстуры
    
    var addColors: [String: String] = [:]                               // словарь доступных цветов для данной модели [ id цвета : значение цвета FFFFFFFF ]
    var addTexture: [String: [String: String]] = [:]                    // словарь доступных текстур для данной модели [ id текстуры :[ тип текстуры : имя файла ]]
    
    var images: [String: String] = [:]                                  // словарь доступных изображений для цветов/текстур  модели [ id цвета/текстуры : имя файла ]
    var textures: [String: String] = [:]                                // словарь текстур по умолчанию для данного элемента модели [ тип текстуры : имя файла ]
    
    var showTransparent: Bool = false                                   // признак что данный элемент может быть прозрачным (выключеным)
    var show: Bool = false                                              // текущее признак показа/не показа набора цветов/текстур
    var transparent: Bool = false                                       // текущий признак прозрачности слоя
    var notShow: Bool { (addColors.count + addTexture.count) < 2}       // вычисляемый признак возможности показа возможности смены цветов/текстур
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case date = "date"
        case idUser = "idUser"
        case idProduct = "idProduct"
        case idPart = "idPart"
        case idColors = "idColors"
        case namePart = "namePart"
        case sort = "sort"
        case name = "name"
        case label = "label"
        case extraCharge = "extraCharge"
        case select = "select"
        case start = "start"
        case addColors = "addColors"
        case addTexture = "addTexture"
        case images = "images"
        case textures = "textures"
        case showTransparent = "showTransparent"
        case show = "show"
        case transparent = "transparent"
    }
    
    init() {}
    
    init(idUser: String, idProduct: String, idPart: String, namePart: String,
         sort: String, name: [String: String], label: [String: String]) {
        self.idUser = idUser
        self.idProduct = idProduct
        self.idPart = idPart
        self.namePart = namePart
        self.sort = sort
        self.name = name
        self.label = label
    }
    
    init(json:[String: Any]) {
        self.id = json["id"] as? String ?? ""
        self.date = json["date"] as? String ?? ""
        self.idUser = json["idUser"] as? String ?? ""
        self.idProduct = json["idProduct"] as? String ?? ""
        self.idPart = json["idPart"] as? String ?? ""
        self.idColors = json["idColors"] as? String ?? ""
        self.namePart = json["namePart"] as? String ?? ""
        self.sort = json["sort"] as? String ?? ""
        self.name = json["name"] as? [String: String] ?? [:]
        self.label = json["label"] as? [String: String] ?? [:]
        self.extraCharge = json["extraCharge"] as? [String: Float] ?? [:]
        self.select = json["select"] as? String ?? ""
        self.start = json["start"] as? String ?? ""
        self.addColors = json["addColors"] as? [String: String] ?? [:]
        self.addTexture = json["addTexture"] as? [String: [String: String]] ?? [:]
        self.images = json["images"] as? [String: String] ?? [:]
        self.textures = json["textures"] as? [String: String] ?? [:]
        self.showTransparent = json["showTransparent"] as? Bool ?? false
        self.show = json["show"] as? Bool ?? false
        self.transparent = json["transparent"] as? Bool ?? false
    }
    
    public init(from decoder: Decoder) throws {
        let isPrint: Bool = false
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.id = try container.decode(String.self, forKey: .id)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля Id", isPrint: isPrint)
            self.id = ""
        }
        do {
            self.date = try container.decode(String.self, forKey: .date)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля Date", isPrint: isPrint)
            self.date = ""
        }
        do {
            self.idUser = try container.decode(String.self, forKey: .idUser)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля IdUser", isPrint: isPrint)
            self.idUser = ""
        }
        do {
            self.idProduct = try container.decode(String.self, forKey: .idProduct)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля idProduct", isPrint: isPrint)
            self.idProduct = ""
        }
        do {
            self.idPart = try container.decode(String.self, forKey: .idPart)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля idPart", isPrint: isPrint)
            self.idPart = ""
        }
        do {
            self.idColors = try container.decode(String.self, forKey: .idColors)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля idColors", isPrint: isPrint)
            self.idColors = ""
        }
        do {
            self.namePart = try container.decode(String.self, forKey: .namePart)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля namePart", isPrint: isPrint)
            self.namePart = ""
        }
        do {
            self.sort = try container.decode(String.self, forKey: .sort)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля Sort", isPrint: isPrint)
            self.sort = ""
        }
        do {
            self.name = try container.decode([String: String].self, forKey: .name)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля Name", isPrint: isPrint)
            self.name = [:]
        }
        do {
            self.label = try container.decode([String:String].self, forKey: .label)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля Label", isPrint: isPrint)
            self.label = [:]
        }
        do {
            self.extraCharge = try container.decode([String: Float].self, forKey: .extraCharge)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля extraCharge", isPrint: isPrint)
            self.extraCharge = [:]
        }
        do {
            self.select = try container.decode(String.self, forKey: .select)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля Select", isPrint: isPrint)
            self.select = ""
        }
        do {
            self.start = try container.decode(String.self, forKey: .start)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля Start", isPrint: isPrint)
            self.start = ""
        }
        do {
            self.addColors = try container.decode([String: String].self, forKey: .addColors)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля addColors", isPrint: isPrint)
            self.addColors = [:]
        }
        do {
            self.addTexture = try container.decode([String: [String: String]].self, forKey: .addTexture)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля addTexture", isPrint: isPrint)
            self.addTexture = [:]
        }
        do {
            self.images = try container.decode([String: String].self, forKey: .images)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля Images", isPrint: isPrint)
            self.images = [:]
        }
        do {
            self.textures = try container.decode([String: String].self, forKey: .textures)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля Textures", isPrint: isPrint)
            self.textures = [:]
        }
        do {
            self.showTransparent = try container.decode(Bool.self, forKey: .showTransparent)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля showTransparent", isPrint: isPrint)
            self.showTransparent = false
        }
        do {
            self.show = try container.decode(Bool.self, forKey: .show)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля Show", isPrint: isPrint)
            self.show = false
        }
        do {
            self.transparent = try container.decode(Bool.self, forKey: .transparent)
        } catch {
            printMessage("ProductPart Ошибка декодирования поля Transparent", isPrint: isPrint)
            self.transparent = false
        }
    }
    
    /// готовить массив для записи
    /// - Returns: массив для записи JSON
    func getJson() -> [String: Any] {
        var data:[String: Any] = [:]
        if !self.id.isEmpty {data["id"] = self.id }
        if !self.idUser.isEmpty {data["idUser"] = self.idUser }
        if !self.idProduct.isEmpty {data["idProduct"] = self.idProduct }
        if !self.idPart.isEmpty {data["idPart"] = self.idPart }
        if !self.idColors.isEmpty {data["idColors"] = self.idColors }
        
        if !self.date.isEmpty {data["date"] = self.date }
        if !self.namePart.isEmpty {data["namePart"] = self.namePart }
        if !self.sort.isEmpty {data["sort"] = self.sort }
        
        if !self.name.isEmpty {data["name"] = self.name }
        if !self.label.isEmpty {data["label"] = self.label }
        if !self.extraCharge.isEmpty {data["extraCharge"] = self.extraCharge }
        if !self.select.isEmpty {data["select"] = self.select }
        if !self.start.isEmpty {data["start"] = self.start }
        if !self.addColors.isEmpty {data["addColors"] = self.addColors }
        if !self.addTexture.isEmpty {data["addTexture"] = self.addTexture }
        
        if !self.images.isEmpty {data["images"] = self.images }
        if !self.textures.isEmpty {data["textures"] = self.textures }
        
        data["show"] = self.show
        data["showTransparent"] = self.showTransparent
        data["transparent"] = self.transparent
        
        return data as [String : Any]
    }
}

/// Вспомогательная модель для фильтрации карточки товара (НАДО ПЕРЕДЕЛАТЬ НА ПРОСТОЙ МАССИВ СТРОК)
struct Filters: Codable {
    var id: String = UUID().uuidString                                                    // id карточки элемента модели товара
    var date: String = Date().timeStamp()                                                 // дата создания или изменения
    var idUser: String = ""                                                               // id пользователя кто создал карточку или изменил ее
    var idProduct: String = ""                                                            // id карточки товара
    var filters: [String] = []                                                            // массив для фильтрации
    var searth: String { filters.reduce("", +).filter({!$0.isWhitespace}).lowercased() }  // общий поисковый стринг без пробелов
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case date = "date"
        case idUser = "idUser"
        case idProduct = "idProduct"
        case filters = "filters"
    }
    
    init() {}
    
    init(idUser: String, idProduct: String, filters: [String]) {
        self.idUser = idUser
        self.idProduct = idProduct
        self.filters = filters
    }
    
    init(json:[String: Any]) {
        self.id = json["id"] as? String ?? ""
        self.date = json["date"] as? String ?? ""
        self.idUser = json["idUser"] as? String ?? ""
        self.idProduct = json["idProduct"] as? String ?? ""
        self.filters = json["filters"] as? [String] ?? []
    }
    
    public init(from decoder: Decoder) throws {
        let isPrint: Bool = false
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.id = try container.decode(String.self, forKey: .id)
        } catch {
            printMessage("Filters Ошибка декодирования поля Id", isPrint: isPrint)
            self.id = ""
        }
        do {
            self.date = try container.decode(String.self, forKey: .date)
        } catch {
            printMessage("Filters Ошибка декодирования поля Date", isPrint: isPrint)
            self.date = ""
        }
        do {
            self.idUser = try container.decode(String.self, forKey: .idUser)
        } catch {
            printMessage("Filters Ошибка декодирования поля IdUser", isPrint: isPrint)
            self.idUser = ""
        }
        do {
            self.idProduct = try container.decode(String.self, forKey: .idProduct)
        } catch {
            printMessage("Filters Ошибка декодирования поля idProduct", isPrint: isPrint)
            self.idProduct = ""
        }
        do {
            self.filters = try container.decode([String].self, forKey: .filters)
        } catch {
            printMessage("Filters Ошибка декодирования поля Filters", isPrint: isPrint)
            self.filters = []
        }
        
    }
    /// готовить массив для записи
    /// - Returns: массив для записи JSON
    func getJson() -> [String: Any] {
        var data:[String: Any] = [:]
        if !self.id.isEmpty {data["id"] = self.id }
        if !self.date.isEmpty {data["date"] = self.date }
        if !self.idUser.isEmpty {data["idUser"] = self.idUser }
        if !self.idProduct.isEmpty {data["idProduct"] = self.idProduct }
        if !self.filters.isEmpty {data["filters"] = self.filters }

        return data as [String : Any]
    }
}
