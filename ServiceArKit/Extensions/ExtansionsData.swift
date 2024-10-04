//
//  ExtansionsData.swift
//  ServiceArKit
//
//  Created by Александр Панин on 04.10.2024.
//
import SwiftUI

extension Data {
    /// Проверка на соответствие размеров изображения
    /// - Parameter size: требуемый размер
    /// - Returns: true если высота и ширина не больше требуемого размера
    func checkSizeImage(to size: CGSize) -> Bool {
        guard let uiImage = UIImage(data: self) else { return false }
        let sizeImage = uiImage.size
        return size.width >= sizeImage.width && size.height >= sizeImage.height
    }
}
