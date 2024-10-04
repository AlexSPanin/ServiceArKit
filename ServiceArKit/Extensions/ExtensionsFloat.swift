//
//  ExtansionsFloat.swift
//  ServiceArKit
//
//  Created by Александр Панин on 04.10.2024.
//

// возвращает текст с разделенными тысячами и знаком рубля

import SwiftUI

extension Float {
    func getRusPrice() -> String {
            let numberForrmatter: NumberFormatter = NumberFormatter()
            numberForrmatter.groupingSeparator = " "
            numberForrmatter.groupingSize = 3
            numberForrmatter.usesGroupingSeparator = true
            numberForrmatter.decimalSeparator = "."
            numberForrmatter.numberStyle = NumberFormatter.Style.decimal
            guard let price = numberForrmatter.string(from: self as NSNumber) as String? else { return ""}
            return price + String(" ₽")
    }
    
    // возвращает стринговый
    func strFormat(count: Int, ext: String) -> String {
        let text = String(format: "%.\(count)f", self)
        let ext = ext.isEmpty ? "" : " \(ext)"
        return text + ext
    }
}
