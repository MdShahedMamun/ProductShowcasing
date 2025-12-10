//
//  ProductShowcasingTests.swift
//  ProductShowcasingTests
//
//  Created by Shahed on 12/9/25.
//

import Testing
import Foundation
import XCTest
@testable import ProductShowcasing


final class MockURLProtocol: URLProtocol {
    static var responses: [URL: (data: Data, statusCode: Int)] = [:]
    
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
    override func startLoading() {
        guard let url = request.url, let mock = MockURLProtocol.responses[url] else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "NoMock", code: -1))
            return
        }
        let response = HTTPURLResponse(
            url: url,
            statusCode: mock.statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: mock.data)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}


final class ProductServiceTests: XCTestCase {
    
    func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }
    
    func makeURL(query: String = "jeans", page: Int = 1) -> URL {
        var components = URLComponents(string: "https://api.hm.com/search-services/v1/sv_se/search/resultpage")!
        components.queryItems = [
            .init(name: "touchPoint", value: "ios"),
            .init(name: "query", value: query),
            .init(name: "page", value: "\(page)")
        ]
        return components.url!
    }
    
    @MainActor
    func test_fetchProducts_success() async throws {
        let session = makeSession()
        let service = ProductService(session: session)
        
        let json = """
          {
            "requestDateTime": "2025-12-09T17:14:27.908Z",
            "responseSource": "Elevate",
            "pagination": {
              "currentPage": 1,
              "nextPageNum": 2,
              "totalPages": 47
            },
            "searchHits": {
              "productList": [
                {
                  "id": "1302894009",
                  "trackingId": "OzU7IzsxMzAyODk0MDA5OyM7IzsvZmFzaGlvbi9NT0JJTEUvU0VBUkNIX1BBR0UvU0VBUkNIX1JFU1VMVDsjOyM7T0JKRUNUSVZFJDsxOzQ3OyM7IzsjOw_e4",
                  "productName": "Flared High Jeans",
                  "external": false,
                  "brandName": "H&M",
                  "url": "/sv_se/productpage.1302894009.html",
                  "showPriceMarker": false,
                  "prices": [
                    {
                      "priceType": "whitePrice",
                      "price": 299,
                      "minPrice": 299,
                      "maxPrice": 299,
                      "formattedPrice": "299,00 kr."
                    }
                  ],
                  "availability": {
                    "stockState": "Available",
                    "comingSoon": false
                  },
                  "swatches": [
                    {
                      "articleId": "1302894009",
                      "url": "/sv_se/productpage.1302894009.html",
                      "colorName": "Vit",
                      "colorCode": "EFEEEA",
                      "trackingId": "OzU7IzsxMzAyODk0MDA5OyM7IzsvZmFzaGlvbi9NT0JJTEUvU0VBUkNIX1BBR0UvU0VBUkNIX1JFU1VMVDsjOyM7T0JKRUNUSVZFJDsxOzQ3OyM7IzsjOw_e4",
                      "productImage": "https://image.hm.com/assets/hm/7d/e9/7de9fcf412b914e797dde8517735bc727830c84e.jpg"
                    },
                    {
                      "articleId": "1302894008",
                      "url": "/sv_se/productpage.1302894008.html",
                      "colorName": "Mörkgrå",
                      "colorCode": "706C6F",
                      "trackingId": "OzU7IzsxMzAyODk0MDA4OyM7IzsvZmFzaGlvbi9NT0JJTEUvU0VBUkNIX1BBR0UvU0VBUkNIX1JFU1VMVDsjOyM7T0JKRUNUSVZFJDsxOzQ3OyM7IzsjOw_e4",
                      "productImage": "https://image.hm.com/assets/hm/ab/69/ab6976e5159c44c759aa23140f3b3519dd1a9db8.jpg"
                    }
                  ],
                  "productMarkers": [],
                  "images": [
                    {
                      "url": "https://image.hm.com/assets/hm/78/4e/784e5c168c94bbc02d429fec28685731706be0fe.jpg"
                    }
                  ]
                },
                {
                  "id": "1313469006",
                  "trackingId": "OzU7IzsxMzEzNDY5MDA2OyM7IzsvZmFzaGlvbi9NT0JJTEUvU0VBUkNIX1BBR0UvU0VBUkNIX1JFU1VMVDsjOyM7T0JKRUNUSVZFJDsyOzQ3OyM7IzsjOw_e4",
                  "productName": "Flared High Jeans",
                  "external": false,
                  "brandName": "H&M",
                  "url": "/sv_se/productpage.1313469006.html",
                  "showPriceMarker": false,
                  "prices": [
                    {
                      "priceType": "whitePrice",
                      "price": 349,
                      "minPrice": 349,
                      "maxPrice": 349,
                      "formattedPrice": "349,00 kr."
                    }
                  ],
                  "availability": {
                    "stockState": "Available",
                    "comingSoon": false
                  },
                  "swatches": [
                    {
                      "articleId": "1313469006",
                      "url": "/sv_se/productpage.1313469006.html",
                      "colorName": "Svart",
                      "colorCode": "000000",
                      "trackingId": "OzU7IzsxMzEzNDY5MDA2OyM7IzsvZmFzaGlvbi9NT0JJTEUvU0VBUkNIX1BBR0UvU0VBUkNIX1JFU1VMVDsjOyM7T0JKRUNUSVZFJDsyOzQ3OyM7IzsjOw_e4",
                      "productImage": "https://image.hm.com/assets/hm/13/f6/13f6bb9194297cc03517990d054940d47e281f7b.jpg"
                    }
                  ],
                  "productMarkers": [],
                  "images": [
                    {
                      "url": "https://image.hm.com/assets/hm/e6/52/e65271fcf6d960c264701aaf8867ec127e50fc05.jpg"
                    }
                  ]
                }
              ]
            }
          }
        """.data(using: .utf8)!
        
        let url = makeURL()
        MockURLProtocol.responses = [url: (json, 200)]
        
        let products = try await service.fetchProducts(query: "jeans", page: 1)
        
        XCTAssertEqual(products.count, 2)
        XCTAssertEqual(products.first?.id, "1302894009")
    }
    
}

final class StubProductService: ProductServiceProtocol {
    var resultPages: [[Product]] = []
    var thrownError: Error? = nil
    var calls: [(query: String, page: Int)] = []
    
    func fetchProducts(query: String, page: Int) async throws -> [Product] {
        calls.append((query, page))
        
        if let err = thrownError {
            throw err
        }
        
        guard page - 1 < resultPages.count else {
            return []
        }
        return resultPages[page - 1]
    }
}

