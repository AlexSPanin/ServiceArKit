//
//  Constant.swift
//  ServiceArKit
//
//  Created by Александр Панин on 02.10.2024.
//

import SwiftUI

let small: CGFloat = 350                                                // критерий малого экрана
let base: CGSize = CGSize(width: 300, height: 500)                      // критерии масштаба к малому экрану

let scaleScreen = UIScreen.main.scale                                   // масштаб экрана устройства
let native = UIScreen.main.nativeScale                                  // реальный масштаб экрана устройства
let bounds = UIScreen.main.bounds
let midPoint = CGPoint(x: bounds.midX, y: bounds.midY)                  // срединная точка экрана

let yPositionScene: Float = -0.005                                        // базовая позиция сцены по вертикали в метрах чуть утоплена

let bundel: String = Bundle.main.appVersion + "." + Bundle.main.appBuild  // для обновления хранилища при обновлении версии программы
let version: String = Bundle.main.appVersion                              // для принудительного обновления при внешней проверке
let nameDevice: String = UIDevice.current.modelName                       // наименование устройства
let iPad: Bool = nameDevice.contains("iPad")                              // признак что устройство iPad

let nameLogo = "ServiceArKit_logo"
let language = "RUS"
let idProduct: String = "512B4379-3EFC-481D-A702-50BBF88F2030"                   // id карточки товара для загрузки модели
let maxData: Int64 = 10 * 1024 * 1024                            // максимальный объем файла для прямого скачивания
let userDefaults = UserDefaults.standard                         // краткая ссылка
let fileDirectory: TypeDirectory = .doc                          // директория для хранения файлов документов, изображения и моделей

// управление печатью в сообщениях
let isPrinting: Bool = true                                    // единый признак печати сообщений в методах
let printObserver: Bool = false                                // включение и печать обзервера печати динамики загрузки файлов


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

let scale: CGFloat = 0.9                                                         // минимальное значение масштабирования по умолчанию

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

// символы не используемые при проверке имени файла
let targetString: [Character] = [Character("$"),
                                 Character("#"),
                                 Character("*"),
                                 Character("{"),
                                 Character("}"),
                                 Character("|"),
                                 Character("?"),
                                 Character("."),
                                 Character("="),
                                 Character(">"),
                                 Character("<"),
                                 Character("%"),
                                 Character("&"),
                                 Character("+"),
                                 Character("~"),
                                 Character("?")]

//
//let nameEntitys: [String: String] = ["line": "line",
//                                     "point": "point",
//                                     "node": "node",
//                                    "text": "text",
//                                     "border": "border",
//                                     "polygon": "polygon",
//                                     "floor": "floor",
//                                     "fence": "fence",
//                                     
//                                     
//                                     

//part0 - голова
//part1 - глаза
//part2 - шея
//part3 - тело
//part4 - плечо правое
//part5 - плечо левое
//part6 - предплечье правое
//part7 - предплечье левое
//part8- кисть левая
//part9 - кисть правая
//part10- таз
//part11- бедро правое
//part12- бедро левое
//part13- голень правая
//part14- голень левая
//part15- стопа правая
//part16- стопа левая
//part17- волосы
