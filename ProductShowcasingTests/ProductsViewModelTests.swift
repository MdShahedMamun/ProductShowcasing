//
//  ProductsViewModelTests.swift
//  ProductShowcasingTests
//
//  Created by Shahed on 12/9/25.
//

import Testing
import Foundation
import XCTest
@testable import ProductShowcasing

final class ProductsViewModelTests: XCTestCase {
    
    func item(_ id: String) -> Product {
        Product(
            id: id,
            productName: "Jeans \(id)",
            brandName: "H&M",
            prices: [Price(formattedPrice: "\(id) SEK")],
            images: [],
            swatches: []
        )
    }
    
    @MainActor
    func test_initialLoad_loadsPage1() async {
        let stub = StubProductService()
        stub.resultPages = [[item("1"), item("2")]]
        
        let viewModel = await MainActor.run { ProductsViewModel(service: stub) }
        
        await viewModel.loadInitialProducts()
        
        XCTAssertEqual(viewModel.products.count, 2)
        XCTAssertEqual(stub.calls.count, 1)
        XCTAssertEqual(stub.calls.first?.page, 1)
    }
    
    @MainActor
    func test_nextPage_appendsProducts() async {
        let stub = StubProductService()
        stub.resultPages = [
            [item("1")],
            [item("2")]
        ]
        
        let viewModel = await MainActor.run { ProductsViewModel(service: stub) }
        
        await viewModel.loadInitialProducts()
        await viewModel.loadProductsForNextPage()
        
        XCTAssertEqual(viewModel.products.map(\.id), ["1", "2"])
        XCTAssertEqual(stub.calls.map(\.page), [1, 2])
    }
    
    @MainActor
    func test_paginationStopsOnEmptyPage() async {
        let stub = StubProductService()
        stub.resultPages = [
            [item("1")],
            [] // empty page -> stop pagination
        ]
        
        let viewModel = await MainActor.run { ProductsViewModel(service: stub) }
        
        await viewModel.loadInitialProducts()
        await viewModel.loadProductsForNextPage()
        await viewModel.loadProductsForNextPage()
        
        XCTAssertEqual(viewModel.products.map(\.id), ["1"])
        XCTAssertEqual(stub.calls.count, 2)
    }
    
    @MainActor
    func test_loadIfNeeded_triggersPaginationForLastItem() async {
        let stub = StubProductService()
        stub.resultPages = [
            [item("1"), item("2")],
            [item("3")]
        ]
        
        let viewModel = await MainActor.run { ProductsViewModel(service: stub) }
        
        await viewModel.loadInitialProducts()
        await viewModel.loadProductsIfNeeded(currentItem: item("2"))
        XCTAssertEqual(viewModel.products.map(\.id), ["1", "2", "3"])
        XCTAssertEqual(stub.calls.count, 2)
    }
    
    @MainActor
    func test_emptyState_afterInitialLoadWithNoResults() async {
        let stub = StubProductService()
        stub.resultPages = [[]]
        
        let viewModel = await MainActor.run { ProductsViewModel(service: stub) }
        
        await viewModel.loadInitialProducts()
        
        XCTAssertEqual(viewModel.products.count, 0)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.lastError)
    }
    
    @MainActor
    func test_errorMapping_invalidURL() async {
        let stub = StubProductService()
        stub.thrownError = ProductError.invalidURL
        
        let viewModel = await MainActor.run { ProductsViewModel(service: stub) }
        
        await viewModel.loadInitialProducts()
        
        XCTAssertEqual(viewModel.errorMessage, "Invalid request URL.")
    }
    
    @MainActor
    func test_errorMapping_decodingFailed() async {
        let stub = StubProductService()
        stub.thrownError = ProductError.decodingFailed
        
        let viewModel = await MainActor.run { ProductsViewModel(service: stub) }
        
        await viewModel.loadInitialProducts()
        
        XCTAssertEqual(viewModel.errorMessage, "Received unexpected data from server.")
    }
    
    @MainActor
    func test_errorMapping_httpError() async {
        let stub = StubProductService()
        stub.thrownError = ProductError.http(statusCode: 500)
        
        let viewModel = await MainActor.run { ProductsViewModel(service: stub) }
        
        await viewModel.loadInitialProducts()
        
        XCTAssertEqual(viewModel.errorMessage, "Server responded with status code 500.")
    }
    
    @MainActor
    func test_errorMapping_networkError() async {
        let stub = StubProductService()
        stub.thrownError = ProductError.network(NSError(domain: "Test", code: -1, userInfo: nil))
        
        let viewModel = await MainActor.run { ProductsViewModel(service: stub) }
        
        await viewModel.loadInitialProducts()
        
        XCTAssertTrue(viewModel.errorMessage?.contains("Network error:") == true)
    }
    
    @MainActor
    func test_retry_callsLoadNextPageAgain() async {
        let stub = StubProductService()
        stub.thrownError = ProductError.http(statusCode: 500)
        
        let viewModel = await MainActor.run { ProductsViewModel(service: stub) }
        
        await viewModel.loadInitialProducts()
        XCTAssertEqual(stub.calls.count, 1)
        
        stub.thrownError = nil
        stub.resultPages = [[item("1")]]
        
        await viewModel.retry()
        XCTAssertEqual(stub.calls.count, 2)
        XCTAssertEqual(viewModel.products.map(\.id), ["1"])
    }
}
