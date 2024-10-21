//
//  FileAppManager.swift
//  ServiceArKit
//
//  Created by Александр Панин on 21.10.2024.
//

import Foundation

final class FileAppManager {
    private let isPrint: Bool = false
    static let shared = FileAppManager()
    private init() {}
    
    /// получение даты создания файла
    /// - Parameters:
    ///   - file: имя файла
    ///   - type: тип директории
    ///   - completion: информация о создании
    func getTimeCreated(to file: String, type: TypeDirectory, completion: @escaping (Date?) -> Void) {
        guard let diretory = type.url, !file.isEmpty else { return completion(nil) }
        let url = diretory.appendingPathComponent(file)
        do {
            let atributtes = try FileManager.default.attributesOfItem(atPath: url.path)
            let date = atributtes[.creationDate] as! Date
            completion( date )
        } catch {
             completion(nil)
        }
    }

    /// удаление файла в локальном и облачном хранилище с обновлением карточки и коллекции с обновлением времени в карточки коллекции
    /// - Parameters:
    ///   - file: имя файла
    ///   - idCard: идентификатор карточки которой пренадлежит
    ///   - collection: тип коллекции
    ///   - local: тип локальной директории
    ///   - cloud: тип облачной директории
    ///   - completion: сообщение
    func deleteFile(to file: String?, idCard: String, collection: NetworkCollection, local: TypeDirectory, cloud: TypeUpload, completion: @escaping(ErrorMessage) -> Void) {
        guard let file = file, !file.isEmpty else { return completion(.error("имя файла пустое")) }
        NetworkManager.shared.deleteFile(type: cloud, file: file) { message in
            switch message {
            case .ok(_):
                NetworkManager.shared.updateSystemTimeStamp(to: collection) { _ in  }
                NetworkManager.shared.updateTimeStamp(to: collection, doc: idCard) { _ in  }
                self.deleteFileLocal(to: file, type: local) { message in completion(message) }
            default: completion(message)
            }
        }
    }
        
    /// удаляем файл в локальной директории определенной ее типом
    /// - Parameters:
    ///   - file: имя файла
    ///   - type: тип директории
    ///   - completion: сообщение
    func deleteFileLocal(to file: String, type: TypeDirectory, completion: @escaping(ErrorMessage) -> Void) {
        guard let directory = type.url, !file.isEmpty else { return completion(.error("имя локального файла пустое")) }
        let url = directory.appendingPathComponent(file)
        do {
            try FileManager.default.removeItem(at: url)
            completion(.ok("локальный файл \(file) удален"))
        } catch {
            completion(.error("удаления локального файла по имени \(file)"))
        }
    }
    
    // загружаем и декодируем файл из директории определенного типа
    func loadFile<T: Decodable>(to name: String, type: TypeDirectory, model: T.Type, complition: @escaping(T?) -> Void) {
        guard let directory = type.url else { return complition(nil) }
        let url = directory.appendingPathComponent(name)
        do {
            let data = FileManager.default.contents(atPath: url.path)
            guard let data = data else { return complition(nil) }
            let decoder = try JSONDecoder().decode(T.self, from: data)
            complition(decoder)
        } catch {
            printMessage("ОШИБКА загрузки файла в файл менеджере", isPrint: isPrint)
            complition(nil)
        }
    }
    
    // кодирование и сохранение файла в директории с определенным видом
    func saveFile<T: Encodable>(to name: String?, type: TypeDirectory, model: T.Type, file: Any) {
        guard let directory = type.url, let name = name, let file = file as? T else { return }
        let url = directory.appendingPathComponent(name)
        do {
            let data = try JSONEncoder().encode(file)
            try data.write(to: url)
        } catch {
            printMessage("ERROR: Save File to File Manager", isPrint: isPrint)
        }
    }
    
    // загружаем файл из директории определенной ее видом и возвращаем DATA
    func loadFileData(to name: String, type: TypeDirectory, complition: @escaping(Data?) -> Void) {
        guard let directory = type.url else { return complition(nil) }
        let url = directory.appendingPathComponent(name)
        do {
            let data = FileManager.default.contents(atPath: url.path)
            complition(data)
        }
    }
    
    // сохранение DATA файла в директории с определенным видом
    func saveFileData (to name: String?, type: TypeDirectory, data: Data?) {
        guard let data = data, let name = name, let directory = type.url else { return }
        let url = directory.appendingPathComponent(name)
        do {
            try data.write(to: url)
        } catch {
            print("ERROR: Save File to File Manager")
        }
    }
    
    // проверяем на наличие файла
    func checkExistFile(to name: String, type: TypeDirectory) -> Bool {
        guard let url = type.url?.appendingPathComponent(name) else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    // проверяем содержание директории в зависимости от ее типа и возвращаем массив файлов
    func checkDirectory(to type: TypeDirectory) -> [String]? {
        guard let directory = type.url else { return nil }
        do {
            let filesInDirectory = try FileManager.default.contentsOfDirectory(atPath: directory.path)
            return filesInDirectory
        } catch {
            return nil
        }
    }
    
    /// удаление отчистка из локальной директории всех файлов
    func clearLocal() {
        let notDelete: [String] = ["google-sdks-events"]
        let files = checkDirectory(to: .assets)
        files?.forEach { file in
            var isDelete = true
            notDelete.forEach { not in
                if file.contains(not), isDelete { isDelete = false }
            }
            if isDelete {
                deleteFileLocal(to: file, type: .assets) { message in printMessage(message.message)  }
            }
        }
    }
}
