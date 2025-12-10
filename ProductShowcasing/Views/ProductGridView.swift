//
//  ProductGridView.swift
//  ProductShowcasing
//
//  Created by Shahed on 12/9/25.
//

import SwiftUI


struct ProductGridView: View {
    @StateObject private var viewModel = ProductsViewModel()
    
    private let gridColumns = Array(
        repeating: GridItem(
            .flexible(),
            spacing: 0
        ),
        count: 2
    )
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.products.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No results found")
                            .font(.title3)
                        Text("We couldn't find any product. Try again.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: gridColumns, spacing: 32) {
                            ForEach(viewModel.products) { product in
                                ProductItemView(product: product)
                                    .buttonStyle(PlainButtonStyle())
                                    .onAppear {
                                        Task {
                                            await viewModel.loadProductsIfNeeded(currentItem: product)
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 0)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                    .padding(.horizontal, 0)
                }
            }
            .navigationTitle("Jeans")
            .onAppear {
                Task { await viewModel.loadInitialProducts() }
            }
            .alert(isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { _ in viewModel.errorMessage = nil })) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Something went wrong."),
                    primaryButton: .default(Text("Retry")) {
                        Task { await viewModel.retry() }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

