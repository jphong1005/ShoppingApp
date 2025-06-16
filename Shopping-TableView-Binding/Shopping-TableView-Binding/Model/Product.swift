//
//  Product.swift
//  Shopping-TableView-Binding
//
//  Created by 홍진표 on 6/15/25.
//

import Foundation

// MARK: - Model

struct Product: Hashable {
    let id: Int
    let name: String
    let imageName: String
    let price: Int
    
    static let collection = [   //  static 키워드는 항상 전역(global)으로 선언되며, 모든 global은 lazy하게 계산됨
        Product(id: 1, name: "iPhone", imageName: "iphone", price: 1),
        Product(id: 2, name: "iPad", imageName: "ipad", price: 3),
        Product(id: 3, name: "MacBook", imageName: "macbook", price: 10),
        Product(id: 4, name: "XBOX", imageName: "xbox.logo", price: 5),
        Product(id: 5, name: "PlayStation", imageName: "playstation.logo", price: 7),
    ]
}
