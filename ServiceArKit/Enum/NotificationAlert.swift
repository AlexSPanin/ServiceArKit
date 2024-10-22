//
//  NotificationAlert.swift
//  ServiceArKit
//
//  Created by Александр Панин on 22.10.2024.
//

import SwiftUI

/// Перечисление текстовых уведомлений
enum NotificationAlert: CaseIterable {
    case mainCondition
    case clearScreen
    case minHeightAlert
    case maxHeigthAlert
    case showAlertDictance
    case callVendor
    case sentOrder
    case addOrder
    case errorURL
    case errorPlace
    case errorCount
    case errorMove
   
    case deniedCamera                     // запрещен доступ к камере
    
    case isConfigARView                   // конфигурация ARView
    case isSearthPlane                    // поиск плоскости
    
    case isErrorNameFile                   // ошибка имени файла
    case isErrorLoadProject                // ошибка загрузки проекта
    case isErrorDistance                   // ошибка перемещения объекта
    case isWarningDistance                 // предупреждение дальней установки
    case isPlaceProject                    // сообщение о размещении проекта
    
    case isCreatedLinks                    // подготовка быстрой ссылки
    
    var notice: (text: String, firstTitle: String, secondTitle: String? ) {
        switch self{
        case .mainCondition: return ("Пожалуйста, примите условия\nПользовательского соглашения", "Понятно", nil)
        case .clearScreen: return ("Вы действительно хотите удалить все объекты и начать с начала?", "Удалить", "Отмена")
        case .minHeightAlert: return ("Достигнута минимальная высота", "Понятно", nil)
        case .maxHeigthAlert: return ("Достигнута максимальная высота", "Понятно", nil)
        case .showAlertDictance: return ("Вы превысили максимальную длинну!\nПожалуйста, перестройте секцию", "Понятно", nil)
        // работа с заказом
        case .callVendor: return ("Позвонить менеджеру?", "Позвонить", "Нет")
        case .sentOrder: return ("Ваша заявка успешно отправлена!\n\nНаш менеджер свяжется с вами в течении 30 минут!", "Отлично!", nil)
        case .addOrder: return ("Ваш заказ принят!\nОн так же сохранен на вашем локальном устройсте.\nВы всегда сможете его найти в сохраненных проектах.\n\nОчистить текущий проект?", "Очистить", "Оставить")
        case .errorURL: return ("Ошибка!\nВыбирите файл проекта.\n(расширение .sar)", "Понятно", nil)
        case .errorPlace: return ("Ошибка определения плоскости!\nПожалуйста, перезапустите поиск плоскости!", "Перезапуск", nil)
        case .errorCount: return ("Предупреждение: Максимальное количество\nДля добавления нового, нужно что-то удалить", "Понятно", nil)
        case .errorMove: return ("Наведите камеру на\nгоризонтальную плоскость", "", nil)
        case .deniedCamera: return ("Без разрешения доступа к камере приложение не может функционировать!\n Перейдите в настройки и разрешите приложению AtRoom использовать камеру.","Перейти", nil)
        case .isSearthPlane: return ("Наведите камеру на пол", "", nil)
        case .isConfigARView: return ("Дождитесь завершения конфигурации", "", nil)
        case .isErrorNameFile: return ("Файл с таким именем уже существует!\nВведите другое наименование.","Понятно", nil)
        case .isErrorLoadProject: return ("Ошибка загрузки проекта!\nПопробуйте другой файл.","Понятно", nil)
        case .isErrorDistance: return ("Ошибка перемещения объекта!\nПопробуйте придвинуть ближе.","", nil)
        case .isWarningDistance: return ("Указатель слишком далеко","", nil)
        case .isPlaceProject: return ("Подождите идет процесс\nразмещения проекта","", nil)
        case .isCreatedLinks: return ("Подождите идет процесс\nподготовки сообщения","", nil)
        }
    }
}


/// Перечисление рисунков уведомлений (символы) и их цвета
enum NotificationLabel: String {
    case info = "info.circle"
    case smile = "face.smiling"
    case video = "video.circle"
    case tap = "hand.tap"
    case question = "questionmark.circle"
    case exclamation = "exclamationmark.circle"
    case phone = "phone.circle"
    
    var sys: Bool {
        switch self {
        case .info, .smile, .video, .tap, .question, .exclamation, .phone: return true
        }
    }
    
    /// переменная отвечающая за цвет
    var color: Color { self == .exclamation ? .redAR : .cyanAR }
}
