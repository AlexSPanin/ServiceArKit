//
//  ProductDataManager.swift
//  ServiceArKit
//
//  Created by Александр Панин on 26.10.2024.
//

import SwiftUI

class ProductDataManager {
    static let shared = ProductDataManager()
    private let isPrint: Bool = true
    private init() {}
    
    /// Получение карточки полной модели
    /// - Parameters:
    ///   - card: карточка коллекции
    ///   - completion: карточка полной модели
    private func fethCard(card: Product, completion: @escaping(Product) -> Void) {
        var productAPP = card
        self.loadSubCollection(to: card.id) { elements in
            self.loadFilter(to: card.id) { filters in
                if let elements = elements { productAPP.elements = elements }
                if let filters = filters { productAPP.filters = filters }
                completion(productAPP)
            }
        }
    }
    
    /// Загрузка всех карточек элементов коллекции
    /// - Parameters:
    ///   - doc: идендификатор карточки коллекции
    ///   - completion: коллекция элементов
    func loadSubCollection(to doc: String, completion: @escaping([ProductPart]?) -> Void) {
        NetworkManager.shared.loadCollectionJson(lev0: .products, id0: doc, lev1: .elements) { data in
            var cards = [ProductPart]()
            data?.forEach{ value in cards.append(ProductPart(json: value)) }
            completion(cards)
        }
    }
    
    /// загрузка данных для фильтрования
    /// - Parameters:
    ///   - doc: идендификатор карточки товара
    ///   - completion: модель для фильтрования
    private func loadFilter(to doc: String, completion: @escaping(Filters?) -> Void) {
        NetworkManager.shared.loadCardJson(lev0: .products, id0: doc, lev1: .filters, id1: NetworkCollection.filters.rawValue) { data in
            guard let data = data else { return completion(nil)}
            completion(Filters(json: data))
        }
    }
    
}
