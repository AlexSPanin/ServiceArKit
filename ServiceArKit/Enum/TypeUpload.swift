//
//  TypeUpload.swift
//  ServiceArKit
//
//  Created by Александр Панин on 21.10.2024.
//
import Foundation
import FirebaseStorage

/// Перечисление типовых облачных директорий
enum TypeUpload: String {

    case temp = "/temp/"                           // временная папка для тестирования
    case data = "/data/"                           // папка для кодированных файлов - неиспользуется
    case image = "/image/"                         // папка для картинок
    case audio = "/audio/"                         // папка для аудио файлов
    case usdz = "/usdz/"                           // папка для файлов моделей IOS
    case glb = "/glb/"                             // папка для файлов моделей Android
    case sar = "/sar/"                             // папка проект/заказов
    case system = "/system/"                       // системная папка - не используется
    case users = "/users/"                         // пользовательская папка  - неиспользуется
    case projects = "/projects/"                   // папка проектов расшариных
    
    var priority: Int {
        switch self {
        case .temp: return 0
        case .data: return 1
        case .image: return 2
        case .audio: return 4
        case .usdz: return 5
        case .system: return 6
        case .users:  return 7
        case .projects:  return 8
        case .sar: return 9
        case .glb: return 10
        }
    }
    
    func filePath(_ userID: String? = nil) -> StorageReference {
        var path = self.rawValue
        if let userID = userID { path += "/" + userID + "/" }
        return Storage.storage().reference(withPath: path)
    }
}


