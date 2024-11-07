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
    
    /// Загрузка карточки коллекции
    /// - Parameters:
    ///   - doc: идендификатор карточки коллекции
    ///   - completion: карточка коллекции
    func loadCard(to doc: String?, completion: @escaping(Product?) -> Void) {
        NetworkManager.shared.loadCardJson(lev0: .products, id0: doc, lev1: nil, id1: nil) { data in
            guard let data = data else { return completion(nil)}
            printMessage("Ответ от сервера: \(String(data: try! JSONSerialization.data(withJSONObject: data, options: .prettyPrinted), encoding: .utf8)!)", isPrint: self.isPrint)
            let card = Product(json: data)
            completion(card)
        }
    }
}
