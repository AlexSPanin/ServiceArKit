//
//  CheckUserPermissions.swift
//  ServiceArKit
//
//  Created by Александр Панин on 22.10.2024.
//

import Foundation
import AVFoundation

/// Проверка прав доступа приложения к ресурсам устройства
final class Permissions {
    
    static let shared = Permissions()
    private init() {}
    
    /// проверка прав доступа
    /// - Returns: булевое значение доступа
    /// - Parameter type: тип ресурса
    func checkPermissions(type: AVMediaType) -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: type)
        printMessage(status == .authorized ? "Есть доступ" : "ОШИБКА: Нет доступа")
        return status == .authorized
    }
    
    /// Запрос на предоставление доступа
    /// - Parameter completion: булевое значение доступа
    /// - Parameter type: тип ресурса
    func requestPermission(type: AVMediaType, completion: @escaping (Bool) -> Void ) {
        AVCaptureDevice.requestAccess(for: type, completionHandler: { accessGranted in
            completion(accessGranted)
        })
    }
}
