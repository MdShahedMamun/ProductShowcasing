//
//  ImageService.swift
//  ProductShowcasing
//
//  Created by Shahed on 12/9/25.
//

import UIKit

actor ImageService {
    static let shared = ImageService()
    func loadImage(with url: URL) async -> UIImage? {
        if let savedImage = await ImageCache.shared.image(with: url) {
            return savedImage
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                await ImageCache.shared.save(image: image, for: url)
                return image
            }
        } catch {
            return nil
        }
        return nil
    }
}
