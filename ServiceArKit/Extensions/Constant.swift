//
//  Constant.swift
//  ServiceArKit
//
//  Created by Александр Панин on 02.10.2024.
//

import SwiftUI

//MARK: - параметры экрана и версии программы
let scaleScreen = UIScreen.main.scale
let native = UIScreen.main.nativeScale
let WIDTH = UIScreen.main.bounds.width > UIScreen.main.bounds.height ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
let HEIGHT = UIScreen.main.bounds.width < UIScreen.main.bounds.height ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
let version = Bundle.main.appVersion                                          // версия программы
let scaleWidth = WIDTH / 300
let scaleHeight = HEIGHT / 500
let portraitView = UIScreen.main.bounds.width < UIScreen.main.bounds.height   // портретный экран при старте
let iPad = UIDevice.current.modelName.contains("iPad")                        // определили что iPad

let nameLogo = "ServiceArKit_logo"

let maxData: Int64 = 10 * 1024 * 1024                          // максимальный объем файла для прямого скачивания
let userDefaults = UserDefaults.standard                       // краткая ссылка
//let local = FileAppManager.shared                              // краткая ссылка на менеджер по работе с локальными файлами
//let network = NetworkManager.shared                            // краткая ссылка на менеджер по работе с сетью
//let db = DataBase.shared                                       // краткая ссылка на менеджер по работе с локальным кешем
//let storage = StorageManager.shared                            // краткая ссылка на менеджер по работе с локальным стораджем

// управление печатью в сообщениях
let isPrinting: Bool = true                                    // единый признак печати сообщений в методах

// коофициент для пересчета элементов при малой ширине экрана
let isSmallWIDTH: Bool = WIDTH < 400
let isSmallHEIGHT: Bool = HEIGHT < 700

// максимальные размеры картинок
let imageLogo: CGSize = CGSize(width: 600, height: 338)        // логотип производителя
let imagePR: CGSize = CGSize(width: 250, height: 250)          // значок изображения текстуры
let imagePhoto: CGSize = CGSize(width: 600, height: 450)       // картинки изображений
let imageBanner: CGSize = CGSize(width: 900, height: 150)      // логотип производителя

let newTypeJSON: Bool = false

// размеры элементов и отступов
let sxx: CGFloat = 2
let sx: CGFloat = 3
let s: CGFloat = 5
let n: CGFloat = 7
let l: CGFloat = 10
let xl: CGFloat = 13
let xxl: CGFloat = 15
let xxx: CGFloat = 20

let hPadding: CGFloat = scaleWidth > 2 ? 30 : 15 * scaleWidth
let vPadding: CGFloat = scaleHeight > 1.5 ? 25 : 15 * scaleHeight

let buttonSize: CGSize = CGSize(width: imageXL , height: imageS)

let stHeightFence: Float = 2.8                                 // стандартная высота ограждения обоев в метрах
let screen: CGFloat = WIDTH * 0.95
let widthNote: CGFloat = WIDTH / scaleWidth
let corner: CGFloat = scaleWidth > 1 ? 10 : 10 * scaleWidth                      // скругление углов поумолчанию
let scale: CGFloat = 0.9                                                         // минимальное значение масштабирования по умолчанию

// размеры изображений
let imageXL: CGFloat = WIDTH / scaleWidth * (isSmallWIDTH ? 0.3 : 0.4)
let imageL: CGFloat = WIDTH / scaleWidth * (isSmallWIDTH ? 0.2 : 0.3)
let imageN: CGFloat = WIDTH / scaleWidth * (isSmallWIDTH ? 0.15 : 0.2)
let imageS: CGFloat = WIDTH / scaleWidth * (isSmallWIDTH ? 0.08 : 0.1)
let pickerL: CGFloat = WIDTH / scaleWidth * (isSmallWIDTH ? 0.05 : 0.06)
let picker: CGFloat = WIDTH / scaleWidth * (isSmallWIDTH ? 0.02 : 0.03)

// цвета для приложения
let mainColor: Color = Color(#colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1))
let mainLigth: Color = Color(#colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1))
let mainRigth: Color =  Color(#colorLiteral(red: 0.3942297101, green: 0.539940834, blue: 0.9582518935, alpha: 1))
let mainGreen: Color =  Color(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1))
let mainBack: Color = Color(#colorLiteral(red: 0.9989674687, green: 0.5950558186, blue: 0.595369339, alpha: 1))
let mainDark: Color = Color(#colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1))

// шрифты для приложения
let fontSx = Font.caption
let fontSm = Font.footnote
let fontS = Font.callout
let fontN = Font.body
let fontL = Font.headline
let fontLX = Font.title
let fontLXX = Font.largeTitle
