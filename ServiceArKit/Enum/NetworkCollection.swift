//
//  NetworkCollection.swift
//  ServiceArKit
//
//  Created by Александр Панин on 21.10.2024.
//

/// Типы и наименования коллекциий в облачном хранилище
enum NetworkCollection: String {
    case system = "system"
    case user = "users"                       // коллекция пользователей основного приложения
    case admin = "admin"                      // коллекция пользователей от производителей
    case notes = "notes"                      // коллекция для отправки пуш сообщений
    case stat = "stat"                        // коллекция по статистики  новая
    case statistic = "statistic"              // коллекция по статистики
    
    //MARK: -  новые коллекции
    case categories = "categories"             // коллекция товарных категорий
    case groups = "groups"                     // коллекция товарных групп
    case proprieties = "proprieties"           // коллекция свойств товаров
    case vendors = "vendors"                   // коллекция производителей/партнеров
    case colors = "colors"                     // коллекция типовых цветов/текстур
    case parts = "parts"                       // коллекция типовых структур/слоев моделей
    case products = "products"                 // коллекция товарных карточек
    case filters = "filters"                   // под коллекция массива фильтрации для товарных карточек
    
    case elements = "elements"                 // коллекция элементов основных коллекций
    
    //MARK: -  коллекции к заказам
    case orders = "orders"                     // коллекция заказов
    case orderProducts = "orderProducts"
    case orderStatus = "orderStatus"
    case orderPayment = "orderPayment"
    
    //MARK: - тестовые коллекции
    case userJSON = "usersJSON"                        // коллекция пользователей основного приложения
    case categoriesJSON = "categoriesJSON"             // коллекция товарных категорий
    case groupsJSON = "groupsJSON"                     // коллекция товарных групп
    case proprietiesJSON = "proprietiesJSON"           // коллекция свойств товаров
    case vendorsJSON = "vendorsJSON"                   // коллекция производителей/партнеров
    case colorsJSON = "colorsJSON"                     // коллекция типовых цветов/текстур
    case partsJSON = "partsJSON"                       // коллекция типовых структур/слоев моделей
    case productsJSON = "productsJSON"                 // коллекция товарных карточек
    
    case ordersJSON = "ordersJSON"                     // коллекция заказов
    
    var collection: String { return self.rawValue }
    
    var system: String {
        switch self {
        case .user: return "user"
        case .categories: return "category"
        case .groups: return "group"
        case .proprieties: return "propriety"
        case .vendors: return "vendor"
        case .colors: return "color"
        case .parts: return "part"
        case .products: return "product"
        case .orders: return "order"
            
        case .userJSON: return "user"
        case .categoriesJSON: return "category"
        case .groupsJSON: return "group"
        case .proprietiesJSON: return "propriety"
        case .vendorsJSON: return "vendor"
        case .colorsJSON: return "color"
        case .partsJSON: return "part"
        case .productsJSON: return "product"
        case .ordersJSON: return "order"
            
        default: return ""
        }
    }
}
