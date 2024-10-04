//
//  Extensions.swift
//  ServiceArKit
//
//  Created by Александр Панин on 04.10.2024.
//

/// Печать сообщения для отладки
/// - Parameters:
///   - message: сообщение
///   - isPrint: локальный признак разрешения печати
func printMessage(_ message: String?, isPrint: Bool = true ) {
    guard isPrinting, isPrint, let message = message else { return }
    debugPrint(message)
}
