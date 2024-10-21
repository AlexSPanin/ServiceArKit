//
//  NetworkManager.swift
//  ServiceArKit
//
//  Created by Александр Панин on 21.10.2024.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseDatabase

var ref: DatabaseReference!

final class NetworkManager {
    private let isPrint: Bool = false
    static let shared = NetworkManager()
    private init() {}
    
    /// Сохранение карточки элемента коллекции в формате под общее декодирование
    /// - Parameters:
    ///   - collection: тип коллекции
    ///   - id: идендификатор карточки
    ///   - model: модель данных
    ///   - data: данные
    ///   - completion: сообщение
    func saveCardCollection<T: Codable>(to collection: NetworkCollection,
                                        id: String?, model: T.Type, any: Any?, completion: @escaping (ErrorMessage) -> Void) {
        guard let id = id, !id.isEmpty else { return completion(.error("нет id либо пустой id"))}
        guard let any = any, let card = any as? T else { return completion(.error("обратного преобразоваия данных")) }
        do {
            let data = try JSONEncoder().encode(card)
            let array = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            saveCardJson(lev0: collection, id0: id, lev1: nil, id1: nil, array: array) { message in completion(message) }
        } catch {
            completion(.error("кодирование карточки \(id)"))
        }
    }
    
    func loadCardCollection<T: Codable>(to collection: NetworkCollection,
                                        id: String?, model: T.Type, completion: @escaping (T?) -> Void) {
        loadCardJson(lev0: collection, id0: id, lev1: nil, id1: nil) { array in
            guard let array = array else { return completion(nil) }
            do {
                let data = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
                let decoder = try JSONDecoder().decode(T.self, from: data)
                completion(decoder)
            } catch {
                completion(nil)
            }
        }
    }
    
    func loadCollection<T: Codable>(to collection: NetworkCollection,
                                    id: String?, model: [T].Type, completion: @escaping ([T]?) -> Void) {
        loadCollectionJson(lev0: collection, id0: nil, lev1: nil) { array in
            guard let array = array else { return completion(nil) }
            do {
                let data = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
                let decoder = try JSONDecoder().decode([T].self, from: data)
               completion(decoder)
            } catch {
                completion(nil)
            }
        }
    }
    
    
}
    
    extension NetworkManager {
    /// записать документ коллекции [String: Any]
    /// - Parameters:
    ///   - collection: тип коллекции
    ///   - name: ид изменяемого.создоваемого документа
    ///   - data: массив с данными
    ///   - completion: пустой комплишн
    func upLoadElementCollection(to collection: NetworkCollection, name: String?, data: [String : Any]?, completion: @escaping (ErrorMessage) -> Void) {
        saveCardJson(lev0: collection, id0: name, lev1: nil, id1: nil, array: data) { message in completion(message) }
    }
    
    /// записать документ под коллекции [String: Any]
    /// - Parameters:
    ///   - collection: тип коллекции
    ///   - doc: ид документа
    ///   - sub: тип под коллекции
    ///   - name: ид изменяемого.создоваемого документа
    ///   - data: массив с данными
    ///   - completion: пустой комплишн
    func upLoadElementSubCollection(to collection: NetworkCollection, doc: String?, sub: NetworkCollection, name: String?, data: [String : Any]?, completion: @escaping (ErrorMessage) -> Void) {
        saveCardJson(lev0: collection, id0: doc, lev1: sub, id1: name, array: data) { message in completion(message) }
    }
    
    /// изменить значение поля элемента в коллекции
    /// - Parameters:
    ///   - collection: тип коллекции
    ///   - document: ид документа
    ///   - key: ключ изменяемого поля документа
    ///   - value: новое значение
    func updateValueElement(to collection: NetworkCollection, document: String?, key: String, value: Any, completion: @escaping (ErrorMessage) -> Void) {
        updateValueJson(lev0: collection, id0: document, lev1: nil, id1: nil, key: key, value: value) { message in  completion(message) }
    }
    
    /// изменить значение поля элемента в под коллекции
    /// - Parameters:
    ///   - collection: тип коллекции
    ///   - document: ид документа коллекции
    ///   - sub: тип подколлекции
    ///   - element: ид документа подколлекции
    ///   - key: ключ изменяемого поля в документе подколлекции
    ///   - value: новое значение
    func updateValueSubElement(to collection: NetworkCollection, document: String?, sub: NetworkCollection, element: String?, key: String, value: Any, completion: @escaping (ErrorMessage) -> Void) {
        updateValueJson(lev0: collection, id0: document, lev1: sub, id1: element, key: key, value: value) { message in completion(message) }
    }
    
    /// удалить карточку коллекции
    /// - Parameters:
    ///   - collection: тип коллекции
    ///   - document: ид документа
    ///   - completion: пустой комплишн
    func deleteElement(to collection: NetworkCollection, document: String?, completion: @escaping (ErrorMessage) -> Void) {
        deleteCardJson(lev0: collection, id0: document, lev1: nil, id1: nil) { message in
            switch message {
            case .ok:
                self.updateSystemTimeStamp(to: collection) { message in completion(message) }
            default:  completion(message)
            }
        }
    }
    
    /// Удаление карточки документа в под коллекции
    /// - Parameters:
    ///   - collection: тип коллекции
    ///   - document: ид документа
    ///   - sub: тип подколлекции
    ///   - element: ид удаляемого документа в подколлекции
    ///   - completion: пустой комплишн
    func deleteSubElement(to collection: NetworkCollection, document: String?, sub: NetworkCollection, element: String?, completion: @escaping (ErrorMessage) -> Void) {
        deleteCardJson(lev0: collection, id0: document, lev1: sub, id1: element) { message in
            switch message {
            case .ok:
                self.updateSystemTimeStamp(to: collection) { message in
                    self.updateTimeStamp(to: collection, doc: document) { message in completion(message) }
                }
            default: completion(message)
            }
           
        }
    }
    
    /// Обновляет  на сервере дату изменения коллекции или карточки
    /// - Parameters:
    ///   - collection: тип коллекции
    ///   - doc: ид документа
    ///   - sub: тип подколлекции
    ///   - element: ид документа под коллекции
    func updateTimeStamp(to collection: NetworkCollection, doc: String?, sub: NetworkCollection? = .elements, element: String? = nil, completion: @escaping (ErrorMessage) -> Void) {
        guard let doc = doc, !doc.isEmpty else { return completion(.error("ид документа пустое"))}
        let time = Date().timeStamp() as Any
        if let sub = sub, let element = element, !element.isEmpty {
            updateValueSubElement(to: collection, document: doc,
                                  sub: sub, element: element,
                                  key: "date", value: time) { message in completion(message) }
        } else {
            loadCardJson(lev0: collection, id0: doc, lev1: nil, id1: nil) { data in
                guard let _ = data else { return }
                self.updateValueElement(to: collection, document: doc, key: "date", value: time) { message in completion(message) }
            }
        }
    }

    ///  изменение временного штампа в системном наборе
    /// - Parameter collection: тип измененной коллекции
    func updateSystemTimeStamp(to collection: NetworkCollection, completion: @escaping (ErrorMessage) -> Void) {
        let key = collection.system
        let time = Date().timeStamp() as Any
        guard !key.isEmpty else { return completion (.error("пустой ключ системной коллекции"))}
        updateValueElement(to: .system, document: "system", key: key, value: time) { message in completion(message) }
    }

    /// Получить дату создания файла
    /// - Parameters:
    ///   - file: название файла
    ///   - type: тип сетевой директории
    ///   - completion: возвращает Дату создания или nil
    func getTimeCreated(to file: String, type: TypeUpload, completion: @escaping (Date?) -> Void) {
        guard !file.isEmpty else { return  completion(nil) }
        let storageRef = type.filePath().child(file)
        storageRef.getMetadata { metadata, error in
            guard let metadata = metadata, let networkDate = metadata.timeCreated else  {  return completion(nil) }
            completion(networkDate)
        }
    }
    
    /// Загрузка коллекции от 0 до 3 уровня вложенности
    /// - Parameters:
    ///   - lev0: коллекция 0 - уровня
    ///   - id0: идендификатор карточки коллекции 0 - уровня
    ///   - lev1: коллекция 1 - уровня
    ///   - id1: идендификатор карточки коллекции 1 - уровня
    ///   - lev2: коллекция 2 - уровня
    ///   - id2: идендификатор карточки коллекции 2 - уровня
    ///   - lev3: коллекция 3  - уровня
    ///   - completion: опциональная коллекция
    func loadCollectionJson(lev0: NetworkCollection?, id0: String?,
                            lev1: NetworkCollection?, id1: String? = nil,
                            lev2: NetworkCollection? = nil, id2: String? = nil,
                            lev3: NetworkCollection? = nil,
                            completion: @escaping ([[String:Any]]?) -> Void ) {
        guard let lev0 = lev0 else {  return completion(nil) }
        ref = Database.database().reference()
        if let id0 = id0, let lev1 = lev1, let id1 = id1, let lev2 = lev2, let id2 = id2 , let lev3 = lev3 {
            guard !id0.isEmpty, !id1.isEmpty, !id2.isEmpty else {  return completion(nil) }
            printMessage("загрузка коллекции на 3-м уровне \(lev2) \(id2)", isPrint: isPrint)
            ref.child(lev0.rawValue).child(id0).child(lev1.rawValue).child(id1).child(lev2.rawValue).child(id2).child(lev3.rawValue).getData { _, snapshots in
                var values = [[String:Any]]()
                let dataSnapshots = snapshots?.children.allObjects as? [DataSnapshot] ?? []
                dataSnapshots.forEach{ snapshot in if let value = snapshot.value as? [String: Any] { values.append(value) } }
                completion(values) }
        } else {
            if let id0 = id0, let lev1 = lev1, let id1 = id1, let lev2 = lev2 {
                guard !id0.isEmpty, !id1.isEmpty else { return completion(nil) }
                printMessage("загрузка коллекции на 2-м уровне \(lev1) \(id1)", isPrint: isPrint)
                ref.child(lev0.rawValue).child(id0).child(lev1.rawValue).child(id1).child(lev2.rawValue).getData { _, snapshots in
                    var values = [[String:Any]]()
                    let dataSnapshots = snapshots?.children.allObjects as? [DataSnapshot] ?? []
                    dataSnapshots.forEach{ snapshot in if let value = snapshot.value as? [String: Any] { values.append(value) } }
                    completion(values) }
            } else {
                if let id0 = id0, let lev1 = lev1 {
                    guard !id0.isEmpty else { return completion(nil) }
                    printMessage("загрузка коллекции на 1-м уровне \(lev0) \(id0)", isPrint: isPrint)
                    ref.child(lev0.rawValue).child(id0).child(lev1.rawValue).getData { _, snapshots in
                        var values = [[String:Any]]()
                        let dataSnapshots = snapshots?.children.allObjects as? [DataSnapshot] ?? []
                        dataSnapshots.forEach{ snapshot in if let value = snapshot.value as? [String: Any] { values.append(value) } }
                        completion(values) }
                } else {
                    printMessage("загрузка коллекции на 0-м уровне \(lev0)", isPrint: isPrint)
                    ref.child(lev0.rawValue).getData { _, snapshots in
                        var values = [[String:Any]]()
                        let dataSnapshots = snapshots?.children.allObjects as? [DataSnapshot] ?? []
                        dataSnapshots.forEach{ snapshot in if let value = snapshot.value as? [String: Any] { values.append(value) } }
                        completion(values) }
                }
            }
        }
    }
  
    /// Загрузка карточки коллекции от 0 до 3 уровня вложенности
    /// - Parameters:
    ///   - lev0: коллекция 0 - уровня
    ///   - id0: идендификатор карточки коллекции 0 - уровня
    ///   - lev1: коллекция 1 - уровня
    ///   - id1: идендификатор карточки коллекции 1 - уровня
    ///   - lev2: коллекция 2 - уровня
    ///   - id2: идендификатор карточки коллекции 2 - уровня
    ///   - lev3: коллекция 3 - уровня
    ///   - id3: идендификатор карточки коллекции 3 - уровня
    ///   - completion: опциональная карточка
    func loadCardJson(lev0: NetworkCollection?, id0: String?,
                      lev1: NetworkCollection?, id1: String?,
                      lev2: NetworkCollection? = nil, id2: String? = nil,
                      lev3: NetworkCollection? = nil, id3: String? = nil,
                      completion: @escaping ([String:Any]?) -> Void ) {
        guard let lev0 = lev0, let id0 = id0, !id0.isEmpty else { return  completion(nil) }
        ref = Database.database().reference()
        if let lev1 = lev1, let id1 = id1, let lev2 = lev2, let id2 = id2 , let lev3 = lev3, let id3 = id3 {
            guard !id1.isEmpty, !id2.isEmpty, !id3.isEmpty else { return completion(nil) }
            printMessage("загрузка карточки на 3-м уровне \(id3)", isPrint: isPrint)
            ref.child(lev0.rawValue).child(id0).child(lev1.rawValue).child(id1).child(lev2.rawValue).child(id2).child(lev3.rawValue).child(id3).getData { _, snapshot in  completion(snapshot?.value as? [String: Any]) }
        } else {
            if let lev1 = lev1, let id1 = id1, let lev2 = lev2, let id2 = id2 {
                guard !id1.isEmpty, !id2.isEmpty else { return completion(nil) }
                printMessage("загрузка карточки на 2-м уровне \(id2)", isPrint: isPrint)
                ref.child(lev0.rawValue).child(id0).child(lev1.rawValue).child(id1).child(lev2.rawValue).child(id2).getData { _, snapshot in  completion(snapshot?.value as? [String: Any]) }
            } else {
                if let lev1 = lev1, let id1 = id1 {
                    guard  !id1.isEmpty else {  return completion(nil) }
                    printMessage("загрузка карточки на 1-м уровне \(id1)", isPrint: isPrint)
                    ref.child(lev0.rawValue).child(id0).child(lev1.rawValue).child(id1).getData { _, snapshot in  completion(snapshot?.value as? [String: Any]) }
                } else {
                    printMessage("загрузка карточки на 0-м уровне \(id0)", isPrint: isPrint)
                    ref.child(lev0.rawValue).child(id0).getData { _, snapshot in completion( snapshot?.value as? [String: Any]) }
                }
            }
        }
    }
    
    /// Сохранение карточки коллекции от 0 до 3 уровня вложенности
    /// - Parameters:
    ///   - lev0: коллекция 0 - уровня
    ///   - id0: идендификатор карточки коллекции 0 - уровня
    ///   - lev1: коллекция 1 - уровня
    ///   - id1: идендификатор карточки коллекции 1 - уровня
    ///   - lev2: коллекция 2 - уровня
    ///   - id2: идендификатор карточки коллекции 2 - уровня
    ///   - lev3: коллекция 3 - уровня
    ///   - id3: идендификатор карточки коллекции 3 - уровня
    ///   - data: массив данных
    ///   - completion: сообщение о результате
    private func saveCardJson(lev0: NetworkCollection?, id0: String?,
                              lev1: NetworkCollection?, id1: String?,
                              lev2: NetworkCollection? = nil, id2: String? = nil,
                              lev3: NetworkCollection? = nil, id3: String? = nil,
                              array: [String : Any]?, completion: @escaping(ErrorMessage) -> Void) {
        guard let lev0 = lev0, let id0 = id0, let data = array, !id0.isEmpty else {  return completion(.error("нет данных или неправельный адрес есть пустой ключ")) }
        ref = Database.database().reference()
        if let lev1 = lev1, let id1 = id1, let lev2 = lev2, let id2 = id2 , let lev3 = lev3, let id3 = id3 {
            guard !id1.isEmpty, !id2.isEmpty, !id3.isEmpty else {  return completion(.error("неправельный адрес есть пустой ключ")) }
            ref.child(lev0.rawValue).child(id0).child(lev1.rawValue).child(id1).child(lev2.rawValue).child(id2).child(lev3.rawValue).child(id3).setValue(data) { (error:Error?, ref:DatabaseReference) in
                let message = "сохранения карточки id3 \(id3)"
                guard error != nil else {  return completion(.ok(message)) }
                completion(.error(message))
            }
        } else {
            if let lev1 = lev1, let id1 = id1, let lev2 = lev2, let id2 = id2 {
                guard !id1.isEmpty, !id2.isEmpty else {  return completion(.error("неправельный адрес есть пустой ключ")) }
                ref.child(lev0.rawValue).child(id0).child(lev1.rawValue).child(id1).child(lev2.rawValue).child(id2).setValue(data) { (error:Error?, ref:DatabaseReference) in
                    let message = "сохранение карточки id2 \(id2)"
                    guard error != nil else {  return completion(.ok(message))}
                    completion(.error(message))
                }
            } else {
                if let lev1 = lev1, let id1 = id1 {
                    guard !id1.isEmpty else {  return completion(.error("неправельный адрес есть пустой ключ")) }
                    ref.child(lev0.rawValue).child(id0).child(lev1.rawValue).child(id1).setValue(data) { (error:Error?, ref:DatabaseReference) in
                        let message = "сохранение карточки id1 \(id1)"
                        guard error != nil else {  return completion(.ok(message))}
                        completion(.error(message))
                    }
                } else {
                    ref.child(lev0.rawValue).child(id0).setValue(data) { (error:Error?, ref:DatabaseReference) in
                        let message = "сохранение карточки id0 \(id0)"
                        guard error != nil else {  return completion(.ok(message))}
                        completion(.error(message))
                    }
                }
            }
        }
    }
    
    /// Удаление карточки коллекции от 0 до 3 уровня вложенности
    /// - Parameters:
    ///   - lev0: коллекция 0 - уровня
    ///   - id0: идендификатор карточки коллекции 0 - уровня
    ///   - lev1: коллекция 1 - уровня
    ///   - id1: идендификатор карточки коллекции 1 - уровня
    ///   - lev2: коллекция 2 - уровня
    ///   - id2: идендификатор карточки коллекции 2 - уровня
    ///   - lev3: коллекция 3 - уровня
    ///   - id3: идендификатор карточки коллекции 3 - уровня
    ///   - completion: сообщение о результате
    private func deleteCardJson(lev0: NetworkCollection?, id0: String?,
                                lev1: NetworkCollection?, id1: String?,
                                lev2: NetworkCollection? = nil, id2: String? = nil,
                                lev3: NetworkCollection? = nil, id3: String? = nil,
                                completion: @escaping(ErrorMessage) -> Void) {
        guard let lev0 = lev0, let id0 = id0, !id0.isEmpty else {  return completion(.error("неправельный адрес есть пустой ключ")) }
        ref = Database.database().reference()
        if let lev1 = lev1, let id1 = id1, let lev2 = lev2, let id2 = id2 , let lev3 = lev3, let id3 = id3 {
            guard !id1.isEmpty, !id2.isEmpty, !id3.isEmpty else { return  completion(.error("неправельный адрес есть пустой ключ")) }
            ref.child(lev0.rawValue).child(id0).child(lev1.rawValue).child(id1).child(lev2.rawValue).child(id2).child(lev3.rawValue).child(id3).removeValue()
            completion(.message("удаление карточки id3 \(id3)"))
        } else {
            if let lev1 = lev1, let id1 = id1, let lev2 = lev2, let id2 = id2 {
                guard !id1.isEmpty, !id2.isEmpty else {  return completion(.error("неправельный адрес есть пустой ключ")) }
                ref.child(lev0.rawValue).child(id0).child(lev1.rawValue).child(id1).child(lev2.rawValue).child(id2).removeValue()
                completion(.message("удаление карточки id2 \(id2)"))
            } else {
                if let lev1 = lev1, let id1 = id1 {
                    guard !id1.isEmpty else {  return completion(.error("неправельный адрес есть пустой ключ")) }
                    ref.child(lev0.rawValue).child(id0).child(lev1.rawValue).child(id1).removeValue()
                    completion(.message("удаление карточки id1 \(id1)"))
                } else {
                    ref.child(lev0.rawValue).child(id0).removeValue()
                    completion(.message("удаление карточки id0 \(id0)"))
                }
            }
        }
    }
    
    /// Обновление поля в карточке коллекции от 0 до 3 уровня вложенности
    /// - Parameters:
    ///   - lev0: коллекция 0 - уровня
    ///   - id0: идендификатор карточки коллекции 0 - уровня
    ///   - lev1: коллекция 1 - уровня
    ///   - id1: идендификатор карточки коллекции 1 - уровня
    ///   - lev2: коллекция 2 - уровня
    ///   - id2: идендификатор карточки коллекции 2 - уровня
    ///   - lev3: коллекция 3 - уровня
    ///   - id3: идендификатор карточки коллекции 3 - уровня
    ///   - key: ключ поля
    ///   - value: новое значение
    ///   - completion: сообщение о результате
    private func updateValueJson(lev0: NetworkCollection?, id0: String?,
                                 lev1: NetworkCollection?, id1: String?,
                                 lev2: NetworkCollection? = nil, id2: String? = nil,
                                 lev3: NetworkCollection? = nil, id3: String? = nil,
                                 key: String, value: Any,
                                 completion: @escaping(ErrorMessage) -> Void) {
        guard let lev0 = lev0, let id0 = id0, !id0.isEmpty, !key.isEmpty else {  return completion(.error("неправельный адрес есть пустой ключ")) }
        ref = Database.database().reference()
        if let lev1 = lev1, let id1 = id1, let lev2 = lev2, let id2 = id2 , let lev3 = lev3, let id3 = id3 {
            guard !id1.isEmpty, !id2.isEmpty, !id3.isEmpty else {  return completion(.error("неправельный адрес есть пустой ключ")) }
            ref.child(lev0.rawValue).child(id0).child(lev1.rawValue).child(id1).child(lev2.rawValue).child(id2).child(lev3.rawValue).child("\(id3)/\(key)").setValue(value) { (error:Error?, ref:DatabaseReference) in
                let message = "сохранения карточки id3 \(id3) по ключу \(key)"
                guard error != nil else {  return completion(.ok(message)) }
                completion(.error(message))
            }
        } else {
            if let lev1 = lev1, let id1 = id1, let lev2 = lev2, let id2 = id2 {
                guard !id1.isEmpty, !id2.isEmpty else { return completion(.error("неправельный адрес есть пустой ключ")) }
                ref.child(lev0.rawValue).child(id0).child(lev1.rawValue).child(id1).child(lev2.rawValue).child("\(id2)/\(key)").setValue(value) { (error:Error?, ref:DatabaseReference) in
                    let message = "сохранения карточки id2 \(id2) по ключу \(key)"
                    guard error != nil else {  return completion(.ok(message)) }
                    completion(.error(message))
                }
            } else {
                if let lev1 = lev1, let id1 = id1, !id1.isEmpty {
                    guard !id1.isEmpty else {  return completion(.error("неправельный адрес есть пустой ключ")) }
                    ref.child(lev0.rawValue).child(id0).child(lev1.rawValue).child("\(id1)/\(key)").setValue(value) { (error:Error?, ref:DatabaseReference) in
                        let message = "сохранения карточки id1 \(id1) по ключу \(key)"
                        guard error != nil else {  return completion(.ok(message)) }
                        completion(.error(message))
                    }
                } else {
                    ref.child(lev0.rawValue).child("\(id0)/\(key)").setValue(value) { (error:Error?, ref:DatabaseReference) in
                        let message = "сохранения карточки id0 \(id0) по ключу \(key)"
                        guard error != nil else {  return completion(.ok(message)) }
                        completion(.error(message))
                    }
                }
            }
        }
    }
}


// MARK: - методы работы с файлами
extension NetworkManager {

    /// Загрузка файла с сервера Data
    /// - Parameters:
    ///   - type: тип директории
    ///   - file: имя файла
    ///   - completion: опциональная дата
    func loadFile(type: TypeUpload, file: String, completion: @escaping (Data?) -> Void) {
        guard !file.isEmpty else {  return completion(nil) }
        let storageRef = type.filePath().child(file)
        storageRef.getData(maxSize: maxData ) { data, _ in completion(data) }
    }
    
    /// Сохранение файла в сетевой директории Data
    /// - Parameters:
    ///   - file: название файла
    ///   - type: тип сетевой директории
    ///   - data: данные для сохранения
    ///   - completion: пустой комплишн
    func saveFile(to file: String, type: TypeUpload, data: Data, completion: @escaping (ErrorMessage) -> Void) {
        guard !file.isEmpty else { return completion(.error("имя файла пустое")) }
        let storageRef = type.filePath().child(file)
        storageRef.putData(data, metadata: nil) { _, error in
            guard error == nil else { return completion(.error("записи файла в FB \(file)")) }
            completion(.ok("файл в FB \(file) записан"))
        }
    }
    
    
    /// Прямой перенос серверного файла на локальное хранилище
    /// - Parameters:
    ///   - type: тип серверного хранилища
    ///   - file: имя файла
    ///   - local: тип локальной директории
    ///   - completion: статус ввиде сообщения
    func loadFileWriteLocal(type: TypeUpload, file: String, local: TypeDirectory, completion: @escaping (ErrorMessage) -> Void) {
        guard !file.isEmpty, let directory = local.url else { return completion(.error("нет данных")) }
        var label = ""
        let storageRef = type.filePath().child(file)
        let url = directory.appendingPathComponent(file)
        printMessage("Файл \(file) начало загрузки из сети", isPrint: isPrint)
        let downloadTask = storageRef.write(toFile: url) { status in
            switch status {
            case .success(_): completion(.message("Файл \(file) успешно загружен в локальное хранилище"))
            case .failure(_): completion(.error("загрузки файла - Файл \(file)"))
            }
        }
        if printObserver {
            storageRef.getMetadata { metadata, error in
                if let size = metadata?.size { label = (Float(size) / 1024).strFormat(count: 2, ext: "КБ") }
                printMessage("Файл \(file) начало загрузки из сети. Объем \(label)", isPrint: self.isPrint)
            }
            downloadTask.observe(.progress) { snapshot in
                let percentComplete = Float(100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)).strFormat(count: 2, ext: "%")
                printMessage("Файл \(file) - \(percentComplete)", isPrint: self.isPrint)
            }
        }
    }
    
    /// Загрузка данных указанной модели из облака
    /// - Parameters:
    ///   - type: тип директории загрузки
    ///   - file: имя файла
    ///   - model: модель данных
    ///   - completion: опциональные декодированные данные
    func loadFile<T: Decodable>(type: TypeUpload, file: String, model: T.Type, completion: @escaping (T?) -> Void) {
        guard !file.isEmpty else {  return completion(nil) }
        let storageRef = type.filePath().child(file)
        storageRef.getData(maxSize: maxData ) { data, _ in
            guard let data = data else { return completion(nil) }
            completion( try? JSONDecoder().decode(T.self, from: data))
        }
    }
    
    /// Сохранение данных указанной модели в облако
    /// - Parameters:
    ///   - file: имя файла
    ///   - type: тип директории выгрузки
    ///   - model: модель данных
    ///   - collection: данные
    ///   - completion: пустой комплишн по завершению
    func saveFile<T: Encodable>(to file: String, type: TypeUpload, model: T.Type, collection: Any, completion: @escaping (ErrorMessage) -> Void) {
        guard !file.isEmpty, let collection = collection as? T else {  return completion(.error("нет данных")) }
        let storageRef = type.filePath().child(file)
        do {
            let data = try JSONEncoder().encode(collection)
            storageRef.putData(data, metadata: nil) { _, error in
                guard error != nil else { return completion(.ok("файл \(file) сохранен"))}
                completion(.error("сохранения данных в файл \(file)"))
            }
        } catch {
            completion(.error("кодирования данных для сохранения в файл \(file)"))
        }
    }
    
    /// удаление файла в хранилище
    /// - Parameters:
    ///   - type: тип сетевой директории
    ///   - file: название файла
    ///   - completion: пустой комплишн
    func deleteFile(type: TypeUpload, file: String, completion: @escaping (ErrorMessage) -> Void) {
        guard !file.isEmpty else {  return completion(.error("имя файла пустое")) }
        let storageRef = type.filePath().child(file)
        storageRef.delete { error in
            guard error == nil else {  return completion(.error("удаления файла в FB \(file)")) }
            completion(.ok("файл в FB \(file) удален"))
        }
    }
}


