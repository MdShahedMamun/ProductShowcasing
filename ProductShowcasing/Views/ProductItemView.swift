//
//  ProductItemView.swift
//  ProductShowcasing
//
//  Created by Shahed on 12/9/25.
//

import SwiftUI


struct ProductItemView: View {
    let product: Product
    
    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var opacity: Double = 0
    @State private var isFavorite = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                imageView
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .clipped()
                
                addTofavorite
                    .padding(16)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(product.brandName ?? "")
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                
                VStack(alignment: .leading, spacing: 1) {
                    
                    Text(product.productName ?? "")
                        .font(.body)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                        .textCase(.uppercase)
                    
                    Text(product.prices.first?.formattedPrice ?? "")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                swatchView
            }
            .padding(.horizontal, 12)
        }
        .task {
            await loadImage()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(accessibilityLabelText()))
        .accessibilityHint(Text("Double tap to view product details"))
    }
    
    private var addTofavorite: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isFavorite.toggle()
            }
        } label: {
            ZStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 20))
                    .foregroundColor(isFavorite ? .red : .black)
            }
            
        }
        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
        .accessibilityHint("Double tap to flip")
    }
    
    private var swatchView: some View {
        let swatches = product.swatches ?? []
        let firstThreeSwatches = Array(swatches.prefix(3))
        let addionalSwatchCount = max(swatches.count - 3, 0)

        return HStack(spacing: 6) {
            ForEach(firstThreeSwatches.indices, id: \.self) { index in
                Rectangle()
                    .fill(Color(hex: firstThreeSwatches[index].colorCode ?? "000000") ?? .black)
                    .frame(width: 11, height: 11)
                    .accessibilityLabel("Color \(firstThreeSwatches[index].colorName ?? "black")")
                    .overlay(
                        Rectangle()
                            .stroke(Color.primary, lineWidth: 1)
                    )
            }
            if addionalSwatchCount > 0 {
                Text("+\(addionalSwatchCount)")
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .accessibilityLabel("Plus \(addionalSwatchCount) more colors")
            }
        }
        .padding(.top, 4)
    }
    
    @ViewBuilder
    private var imageView: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        opacity = 1
                    }
                }
            
        } else if isLoading {
            ProgressView()
        } else {
            Image(systemName: "photo")
                .font(.system(size: 37))
                .foregroundColor(.secondary)
        }
    }
    
    private func loadImage() async {
        guard let url = product.images?.first?.url else { return }
        isLoading = true
        defer { isLoading = false }
        let image = await ImageService.shared.loadImage(with: url)
        await MainActor.run {
            self.image = image
        }
    }
    
    private func accessibilityLabelText() -> String {
        let title = product.productName ?? "unknown product"
        let price = product.prices.first?.formattedPrice ?? "unknown price"
        return "\(title), \(price)"
    }
}
