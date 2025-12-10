//
//  ProductsViewModel.swift
//  ProductShowcasing
//
//  Created by Shahed on 12/9/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ProductsViewModel: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var lastError: Error? = nil
    
    private var page = 1
    private var canLoadMore = true
    private let service: ProductServiceProtocol
    private let query = "jeans"
    
    init(service: ProductServiceProtocol) {
        self.service = service
    }
    
    convenience init() {
        self.init(service: ProductService())
    }
    
    func loadInitialProducts() async {
        page = 1
        canLoadMore = true
        products = []
        errorMessage = nil
        lastError = nil
        await loadProductsForNextPage()
    }
    
    func loadProductsForNextPage() async {
        guard !isLoading && canLoadMore else { return }
        isLoading = true
        errorMessage = nil
        lastError = nil
        
        do {
            let fetchedProducts = try await service.fetchProducts(query: query, page: page)
            if fetchedProducts.isEmpty {
                canLoadMore = false
                if products.isEmpty {
                    errorMessage = nil
                }
            } else {
                products.append(contentsOf: fetchedProducts)
                page += 1
            }
        } catch {
            lastError = error
            errorMessage = mapErrorToMessage(error)
        }
        isLoading = false
    }
    
    func loadProductsIfNeeded(currentItem item: Product) async {
        guard let last = products.last else { return }
        if item.id == last.id {
            await loadProductsForNextPage()
        }
    }
    
    func retry() async {
        await loadProductsForNextPage()
    }
    
    private func mapErrorToMessage(_ error: Error) -> String {
        if let pe = error as? ProductError {
            switch pe {
            case .invalidURL:
                return "Invalid request URL."
            case .decodingFailed:
                return "Received unexpected data from server."
            case .http(let code):
                return "Server responded with status code \(code)."
            case .network(let underlying):
                return "Network error: \(underlying.localizedDescription)"
            }
        } else {
            return (error as NSError).localizedDescription
        }
    }
}
