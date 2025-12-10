//
//  Product.swift
//  ProductShowcasing
//
//  Created by Shahed on 12/9/25.
//

import Foundation

struct ProductSearchResponse: Codable {
    let searchHits: SearchHits?
    let pagination: Pagination
}

struct SearchHits: Codable {
    let productList: [Product]?
    let numberOfHits: Int?
}

struct Product: Codable, Identifiable, Equatable {
    let id: String
    let productName: String?
    let brandName: String?
    let prices: [Price]
    let images: [ProductImage]?
    let swatches: [ProductSwatch]?
}

struct Price: Codable, Equatable {
    let formattedPrice: String?
}

struct ProductImage: Codable, Equatable {
    let url: URL?
}

struct ProductSwatch: Codable, Equatable {
    let colorCode: String?
    let colorName: String?
}

struct Pagination: Codable {
    let currentPage: Int
    let totalPages: Int
}
