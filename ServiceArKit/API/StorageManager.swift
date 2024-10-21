//
//  StorageManager.swift
//  ServiceArKit
//
//  Created by Александр Панин on 21.10.2024.
//

import Foundation

final class StorageManager {
    // список ключей
    enum TypeKey: Codable, CaseIterable {
        case app, id, user, exit, lidar, vendor, system, project, save,
             category, group, propriety, color, part, product, hello,
             flash, links, catalog, first, users, admin,
             firstSearch, firstCatalog, firstCard, firstDel,
             bundel, education
        
        var key: String {
            switch self {
            case .id: return "keyId"                                  // ключ для хранения id пользователя
            case .app: return "keyApp"                                // ключ для хранения данных приложения
            case .first: return "keyFirst"                            // ключ признак первого входа
            case .hello: return "keyHello"                            // ключ признак приветственного экрана
            case .flash: return "keyFlash"                            // ключ признак мигания кнопки установки
            case .links: return "keyLinks"                            // ключ к типу перехода при установке программы содержит idVendor
            case .catalog: return "keyCatalog"                        // ключ уведомления первого перехода в каталог
            case .exit: return "keyExit"                              // ключ признак выхода из аккаунта
            case .lidar: return "keyLidar"                            // ключ признак уведомления при работе лидара
            
            case .education: return "keyEducation"                    // ключ признак прохождения обучения
            case .firstSearch: return "keyFirstSearch"                // ключ признак первого поиска плоскости
            case .firstCatalog: return "keyFirstCatalog"              // ключ признак первого использования каталога
            case .firstCard: return "keyFirstCard"                    // ключ признак первого использования карточки товара
            case .firstDel: return "keyFirstDel"                      // ключ признак после первой установки товара
                
            case .project: return "keyProject"
            case .save: return "keySave"
                
            case .admin: return "keyAdmin"                            // ключ для хранения модели [AdminUser] пользователя
            case .user: return "keyUser"                              // ключ для хранения модели UserAPP пользователя
            case .users: return "keyUsers"                            // ключ для хранения массива моделей [UserAPP] пользователя
            case .system: return "keySystem"                          // ключ для хранения модели системных данных SystemApp
            case .vendor: return "keyVendor"                          // ключ для хранения массива моделей [VendorAPP] поставщиков
            case .category: return "keyCategory"                      // ключ для хранения массива моделей [Category] продуктовых категорий
            case .group: return "keyGroup"                            // ключ для хранения массива моделей [ProductGroup] продуктовых групп
            case .propriety: return "keyPropriety"                    // ключ для хранения массива моделей [ProductPropriety] продуктовых свойств
            case .color: return "keyColor"                            // ключ для хранения массива моделей [ColorAPP] цветовых коллекций
            case .part: return "keyPart"                              // ключ для хранения массива моделей [PartsAPP] коллекций видов составных частей
            case .product: return "keyProduct"                        // ключ для хранения массива моделей [ProductAPP] карточек товара
            case .bundel: return "keyBundel"                          // ключ для хранения версии
            }
        }
    }
    private let isPrint: Bool = false
    static let shared = StorageManager.init()
    
    private init () {}
    
    /// Проверка ключа
    /// - Parameter type: тип ключа
    /// - Returns: булевое значения ключа
    func checkKey(type: TypeKey) -> Bool { UserDefaults.standard.bool(forKey: type.key) }
    
    /// Установка ключа
    /// - Parameters:
    ///   - type: тип ключа
    ///   - key: булевое значение ключа
    func settingKey(to type: TypeKey, key: Bool) { UserDefaults.standard.set(key, forKey: type.key) }
    
    /// Запись стрингового ключа
    /// - Parameters:
    ///   - type: тип ключа
    ///   - label: значение ключа
    func saveString(type: TypeKey, label: String) { UserDefaults.standard.set(label, forKey: type.key) }
    
    /// Чтение стрингового ключа
    /// - Parameter type: тип ключа
    /// - Returns: опциональное значение ключа
    func loadString(type: TypeKey) -> String? { UserDefaults.standard.string(forKey: type.key) }
    
    /// чтение модели данных по ключу
    /// - Parameters:
    ///   - type: тип ключа
    ///   - model: модель данных
    ///   - completion: опциональные декодированные данные
    func load<T: Decodable>(type: TypeKey, model: T.Type, completion: @escaping(T?) -> Void) {
        guard let data = UserDefaults.standard.object(forKey: type.key) as? Data else { return completion(nil) }
        do {
            let decoder = try? JSONDecoder().decode(T.self, from: data)
            completion(decoder)
        }
    }
    
    /// Запись модели данных по ключу
    /// - Parameters:
    ///   - type: тип ключа
    ///   - model: модель данных
    ///   - collection: данные
    func save<T: Encodable>(type: TypeKey, model: T.Type, collection: Any ) {
        guard let collection = collection as? T else { return }
        do {
            let data = try JSONEncoder().encode(collection)
            UserDefaults.standard.set(data, forKey: type.key)
        } catch {
            printMessage("Ошибка сохранения в память \(type.key)", isPrint: isPrint)
        }
    }
    
    /// Удаление ключа
    /// - Parameter type: тип ключа
    func remove(type: TypeKey) { UserDefaults.standard.removeObject(forKey: type.key)  }

    /// сброс стороджа
    func clearStorage() { TypeKey.allCases.forEach { key in remove(type: key) } }
    
}

