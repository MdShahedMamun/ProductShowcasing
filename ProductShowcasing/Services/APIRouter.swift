//
//  APIRouter.swift
//  ProductShowcasing
//
//  Created by Shahed on 12/9/25.
//

import Foundation

enum APIRouter {
    case searchProducts(query: String, page: Int)
    
    private var scheme: String { "https" }
    private var host: String { "api.hm.com" }
    
    private var path: String {
        switch self {
        case .searchProducts:
            return "/search-services/v1/sv_se/search/resultpage"
        }
    }
    
    var method: String {
        switch self {
        case .searchProducts:
            return "GET"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .searchProducts(let query, let page):
            return [
                URLQueryItem(name: "touchPoint", value: "ios"),
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: String(page))
            ]
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems
        guard let url = components.url else {
            throw ProductError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        return request
    }
}
