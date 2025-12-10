//
//  ProductServices.swift
//  ProductShowcasing
//
//  Created by Shahed on 12/9/25.
//

import Foundation

protocol ProductServiceProtocol {
    func fetchProducts(query: String, page: Int) async throws -> [Product]
}

enum ProductError: Error {
    case invalidURL
    case decodingFailed
    case http(statusCode: Int)
    case network(Error)
}

final class ProductService: ProductServiceProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchProducts(query: String, page: Int) async throws -> [Product] {
        let request = try APIRouter.searchProducts(query: query, page: page).asURLRequest()
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw ProductError.http(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            do {
                let decoded = try JSONDecoder().decode(ProductSearchResponse.self, from: data)
                print("decoded response = \(decoded)")
                return decoded.searchHits?.productList ?? []
            } catch {
                throw ProductError.decodingFailed
            }
        } catch {
            throw ProductError.network(error)
        }
    }
}
