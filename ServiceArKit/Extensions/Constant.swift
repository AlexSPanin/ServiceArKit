//
//  Constant.swift
//  ServiceArKit
//
//  Created by Александр Панин on 02.10.2024.
//

import SwiftUI

let small: CGFloat = 400
let base: CGSize = CGSize(width: 300, height: 500)

//MARK: - параметры экрана и версии программы
let scaleScreen = UIScreen.main.scale
let native = UIScreen.main.nativeScale

let yPositionScene: Float = -0.005                                        // базовая позиция сцены по вертикали в метрах чуть утоплена

let bundel: String = Bundle.main.appVersion + "." + Bundle.main.appBuild  // для обновления хранилища при обновлении версии программы
let version: String = Bundle.main.appVersion                              // для принудительного обновления при внешней проверке
let nameDevice: String = UIDevice.current.modelName                       // наименование устройства
let iPad: Bool = nameDevice.contains("iPad")                              // признак что устройство iPad

let nameLogo = "ServiceArKit_logo"

let idProduct: String = ""                                       // id карточки товара для загрузки модели
let maxData: Int64 = 10 * 1024 * 1024                            // максимальный объем файла для прямого скачивания
let userDefaults = UserDefaults.standard                         // краткая ссылка

//let local = FileAppManager.shared                              // краткая ссылка на менеджер по работе с локальными файлами
//let network = NetworkManager.shared                            // краткая ссылка на менеджер по работе с сетью
//let db = DataBase.shared                                       // краткая ссылка на менеджер по работе с локальным кешем
//let storage = StorageManager.shared                            // краткая ссылка на менеджер по работе с локальным стораджем

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
