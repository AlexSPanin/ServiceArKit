//
//  ErrorMessage.swift
//  ServiceArKit
//
//  Created by Александр Панин on 21.10.2024.
//

/// Сообщения для отработки пустых комплишн
enum ErrorMessage: Error {
    case ok(String), error(String), message(String)                                               // составные ошибки и уведомления
    var message: String {
        switch self {
        case .ok(let string): return "OK: \(string)"
        case .error(let string): return "ОШИБКА: \(string)"
        case .message(let string): return "УВЕДОМЛЕНИЕ: \(string)"
        }
    }
}

/// Признаки для отработки типов ответа
enum TypeRaycastError {
    case no, querry, result
}
