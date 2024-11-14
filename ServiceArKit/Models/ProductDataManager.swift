//
//  ProductDataManager.swift
//  ServiceArKit
//
//  Created by Александр Панин on 26.10.2024.
//

import SwiftUI

class ProductDataManager {
    static let shared = ProductDataManager()
    private let isPrint: Bool = false
    private init() {}
    
    /// Загрузка карточки коллекции
    /// - Parameters:
    ///   - doc: идендификатор карточки коллекции
    ///   - completion: карточка коллекции
    func loadCard(to doc: String?, completion: @escaping(Product?) -> Void) {
        NetworkManager.shared.loadCardJson(lev0: .products, id0: doc, lev1: nil, id1: nil) { array in
            guard let array = array else { return completion(nil)}
            do {
                
                let data = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
                printMessage("\(data)")
                let product = try JSONDecoder().decode(Product.self, from: data)
                completion(product)
            } catch {
                completion(nil)
            }
        }
    }
}

