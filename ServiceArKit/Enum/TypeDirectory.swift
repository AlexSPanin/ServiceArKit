//
//  TypeDirectory.swift
//  ServiceArKit
//
//  Created by Александр Панин on 21.10.2024.
//
import Foundation

/// типы используемых локальных директорий
enum TypeDirectory: Codable {
    case doc, temp, assets, cache
    var url: URL? {
        switch self {
        case .doc: return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        case .temp: return FileManager.default.temporaryDirectory
        case .assets: return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        case .cache: return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        }
    }
}
