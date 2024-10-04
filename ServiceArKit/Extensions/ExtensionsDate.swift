//
//  ExtansionsDate.swift
//  ServiceArKit
//
//  Created by Александр Панин on 04.10.2024.
//
import SwiftUI

//MARK: - методы преобразования даты
extension Date {
    /// Преобразование даты к форматированной строке
    /// - Returns: год-месяц-дата часы:мин:сек
    func timeStamp() -> String {
        let date = DateFormatter()
        date.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return date.string(from: self)
    }

    /// Преобразование даты к форматированной строке
    /// - Returns: год-месяц-дата часы:мин
    func shortTimeStamp() -> String {
        let date = DateFormatter()
        date.dateFormat = "yy-MM-dd HH:mm"
        return date.string(from: self)
    }

    /// Преобразование даты к форматированной строке
    /// - Returns: год-месяц-дата
    func shortDate() -> String {
        let date = DateFormatter()
        date.dateFormat = "yy-MM-dd"
        return date.string(from: self)
    }

    /// Преобразование даты к форматированной строке
    /// - Returns: часы:мин
    func shortHours() -> String {
        let date = DateFormatter()
        date.dateFormat = "HH:mm"
        return date.string(from: self)
    }
}
