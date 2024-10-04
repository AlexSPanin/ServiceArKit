//
//  ExtansionsURL.swift
//  ServiceArKit
//
//  Created by Александр Панин on 04.10.2024.
//

import SwiftUI

extension URL {
    
    /// проверка расширения файла
    /// - Parameter ext: расширение файла без точки
    /// - Returns: true - если совпадают
    func checkExt(to ext: String) -> Bool {
        let last = self.lastPathComponent
        guard let index = last.lastIndex(of: ".") else { return false }
        let i = last.index(after: index)
        let extURL = String(last[i...])
        return extURL.lowercased() == ext.lowercased()
    }
    
    /// проверка расширения файла из заданного массива расширений без точек
    /// - Parameter exts: массив расширений
    /// - Returns: true если присутствует хоть одно расширение
    func checkExts(to exts: [String]) -> Bool {
        var check = false
        let last = self.lastPathComponent
        guard let index = last.lastIndex(of: ".") else { return check }
        let i = last.index(after: index)
        let extURL = String(last[i...]).lowercased()
        exts.forEach { ext in
            if !check && extURL == ext.lowercased() { check = true }
        }
        return check
    }
    
    /// получить текстовое значение расширения файла
    /// - Returns: расширение файла с точкой
    func getExt() -> String? {
        let last = self.lastPathComponent
        guard let index = last.lastIndex(of: ".") else { return nil }
        let i = last.index(after: index)
        let extURL = String(last[i...]).lowercased()
        return String(".\(extURL)")
    }
}
