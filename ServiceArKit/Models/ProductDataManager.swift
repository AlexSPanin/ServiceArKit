//
//  ProductDataManager.swift
//  ServiceArKit
//
//  Created by Александр Панин on 26.10.2024.
//

import SwiftUI

class ProductDataManager {
    static let shared = ProductDataManager()
    private init() {}
    
    /// Загрузка карточки коллекции
    /// - Parameters:
    ///   - doc: идендификатор карточки коллекции
    ///   - completion: карточка коллекции
    func loadCard(to doc: String?, completion: @escaping(Product?) -> Void) {
        NetworkManager.shared.loadCardJson(lev0: .products, id0: doc, lev1: nil, id1: nil) { data in
            guard let data = data else { return completion(nil)}
            var product = Product(json: data)
            NetworkManager.shared.loadCollectionJson(lev0: .products, id0: doc, lev1: .elements) { data in
                var cards = [ProductPart]()
                data?.forEach{ value in cards.append(ProductPart(json: value)) }
                product.elements = cards
                completion(product)
            }
        }
    }
}

