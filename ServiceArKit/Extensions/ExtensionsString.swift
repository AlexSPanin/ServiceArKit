//
//  ExtansionsString.swift
//  ServiceArKit
//
//  Created by Александр Панин on 04.10.2024.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

extension String {
    
    // обрезает справа строку от первого встретившевося символа (включая символ)
    func getInterval(to start: Int, count: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: start)
        let finish = self.index(start, offsetBy: count)
        let range = start..<finish
        return String(self[range])
    }
    
    // обрезает справа строку от первого встретившевося символа (включая символ)
    func croppStartToFirstSymbol(_ symbol: Character) -> String {
        guard let index = self.firstIndex(of: symbol) else {  return self }
        return String(self[..<index])
    }
    
    // обрезает слева строку от первого встретившевося символа (включая символ)
    func croppFirstSymbolToFinish(_ symbol: Character) -> String {
        guard let index = self.firstIndex(of: symbol) else { return self }
        let i = self.index(after: index)
        return String(self[i...])
    }
    
    // обрезает справа строку от последнего встретившевося символа (включая символ)
    func croppStartToLastSymbol(_ symbol: Character) -> String {
        guard let index = self.lastIndex(of: symbol) else { return self }
        return String(self[..<index])
    }
    
    // обрезает слева строку от последнего встретившевося символа (включая символ)
    func croppLastSymbolToFinish(_ symbol: Character) -> String {
        guard let index = self.lastIndex(of: symbol) else { return self }
        let i = self.index(after: index)
        return String(self[i...])
    }
    
    // проверяем наличие символа
    func checkSimbol(_ element: Character) -> Bool { self.contains(where: {$0 == element}) }
    
    // проверка массива расширений
    func checkExts(to exts: [String]) -> Bool {
        var check = false
        guard let index = self.lastIndex(of: ".") else { return check }
        let i = self.index(after: index)
        let extSelf = String(self[i...]).lowercased()
        exts.forEach { ext in
            if !check && extSelf == ext.lowercased() { check = true }
        }
        return check
    }
    
    // генератор QR кода
    func generateQRCode() -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(self.utf8)
        let transform = CGAffineTransform(scaleX: 30, y: 30)
        guard let outputImage = filter.outputImage?.transformed(by: transform) else { return nil}
        guard let cgimg = context.createCGImage(outputImage, from: outputImage.extent)  else { return nil }
        return UIImage(cgImage: cgimg)
    }
    
    // генератор QR кода
    func generateQRCodeData() -> Data? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(self.utf8)
        let transform = CGAffineTransform(scaleX: 30, y: 30)
        guard let outputImage = filter.outputImage?.transformed(by: transform) else { return nil}
        guard let cgimg = context.createCGImage(outputImage, from: outputImage.extent)  else { return nil }
        return cgimg.png
    }
    
    // возвращает дату из текста формат "yyyy-MM-dd hh:mm:ss" иначе nil
    func timeStamp() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "Europe/Moscow")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: self)
    }
    
    // возвращает дату из текста формат "yyyy-MM-dd hh:mm" иначе nil
    func shortTimeStamp() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "Europe/Moscow")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.date(from: self)
    }
    
    enum Target: String {
        case phone = "[^0-9]"
        case uuid = "[^0-Z]"
        case hex = "[^0-F]"
    }
    
    func format(with maskX: String, target: Target) -> String {
        
        let values = self.replacingOccurrences(of: target.rawValue, with: "", options: .regularExpression)
        var result = ""
        var index = values.startIndex // numbers iterator

        // iterate over the mask characters until the iterator of numbers ends
        for ch in maskX where index < values.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(values[index])

                // move numbers iterator to the next index
                index = values.index(after: index)

            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
    
}

