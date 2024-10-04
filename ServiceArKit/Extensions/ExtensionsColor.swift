//
//  ExtansionsColor.swift
//  ServiceArKit
//
//  Created by Александр Панин on 04.10.2024.
//

import SwiftUI

//MARK: - кодирование и декодирование UIColor
@propertyWrapper
struct CodableColor {
    var wrappedValue: UIColor
}

extension CodableColor: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        guard let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid color"
            )
        }
        wrappedValue = color
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let data = try NSKeyedArchiver.archivedData(withRootObject: wrappedValue, requiringSecureCoding: true)
        try container.encode(data)
    }
}

extension UIColor {
    /// инициатор цвета UIColor по текстовой маске #FFFFFFFF
    /// - Parameter hex: маска цвета
    public convenience init (hex: String) {
        let r, g, b, a: CGFloat
        var hexColor = hex.lowercased()
        if hexColor.count == 6 { hexColor += "ff"  }
        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            
            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                a = CGFloat(hexNumber & 0x000000ff) / 255
                self.init(red: r, green: g, blue: b, alpha: a)
                return
            }
        }
        self.init(red: 1, green: 1, blue: 1, alpha: 1)
        return
    }
}

extension Color {
    
    //MARK: - предустановленные цвета
    //    static let mainFoneAR = Color(#colorLiteral(red: 0.08053366095, green: 0.09691237658, blue: 0.1783965826, alpha: 1))
    //    static let greenAR = Color(#colorLiteral(red: 0.2196078431, green: 0.6901960784, blue: 0, alpha: 1))
    //    static let darkGreenAR = Color(#colorLiteral(red: 0.1911668777, green: 0.3707632422, blue: 0.2023646832, alpha: 1))
        static let blackAR = Color(#colorLiteral(red: 0.1285863519, green: 0.1285863519, blue: 0.1285863519, alpha: 1)).opacity(0.8)
    //    static let grayAR = Color(#colorLiteral(red: 0.6658725142, green: 0.6658725142, blue: 0.6658724546, alpha: 1))
    //    static let ligthGrayAR = Color(#colorLiteral(red: 0.7530785203, green: 0.7530786395, blue: 0.7530786395, alpha: 1))
    //    static let brownAR = Color(#colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1)).opacity(0.1)
    //    static let ligthBrownAR = Color(#colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1)).opacity(0.05)
    //    static let darkBrownAR = Color(#colorLiteral(red: 0.392156899, green: 0.3921568394, blue: 0.392156899, alpha: 1)).opacity(0.5)
    //    static let darkGrayAR = Color(#colorLiteral(red: 0.392156899, green: 0.3921568394, blue: 0.392156899, alpha: 1))
        static let cyanAR = Color(#colorLiteral(red: 0.3942297101, green: 0.539940834, blue: 0.9582518935, alpha: 1))
        static let ligthCyanAR = Color(#colorLiteral(red: 0.2977530956, green: 0.8079112768, blue: 0.9619736075, alpha: 1))
        static let redAR = Color(#colorLiteral(red: 0.9989674687, green: 0.5950558186, blue: 0.595369339, alpha: 1))
    //    static let whiteAR = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    //    static let gradirntAR =  LinearGradient(gradient: Gradient(colors: [.cyanAR, .ligthCyanAR]), startPoint: .leading, endPoint: .trailing)
    
    /// установка цвета в формате #FFFFFFFF
    /// - Parameter hex: маска цвета
    /// - Returns: цвет
    func hex(hex: String) -> Color {
        let uiColor = UIColor.init(hex: hex)
        return Color(uiColor: uiColor)
    }
    
    /// получение маски цвета
    /// - Returns: маска цвета в формате #FFFFFFFF
    func hexDescription() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        let ui = UIColor(self)
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(
            format: "%02X%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff),
            Int(a * 0xff)
        )
    }
}

