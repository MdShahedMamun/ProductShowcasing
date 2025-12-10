//
//  ImageCache.swift
//  ProductShowcasing
//
//  Created by Shahed on 12/9/25.
//

import UIKit

protocol ImageCacheType {
    func image(with url: URL) -> UIImage?
    func save(image: UIImage?, for url: URL)
}

final class ImageCache: ImageCacheType {
    static let shared = ImageCache()
    private let memory = NSCache<NSURL, UIImage>()
    private let fileManager = FileManager.default
    
    private init() {}
    
    func image(with url: URL) -> UIImage? {
        if let image = memory.object(forKey: url as NSURL) {
            return image
        }
        if let disk = loadFromDisk(url: url) {
            memory.setObject(disk, forKey: url as NSURL)
            return disk
        }
        return nil
    }
    
    func save(image: UIImage?, for url: URL) {
        guard let image else { return }
        memory.setObject(image, forKey: url as NSURL)
        saveToDisk(image: image, url: url)
    }
    
    private func cachePath(for url: URL) -> URL? {
        guard let base = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }
        return base.appendingPathComponent(url.lastPathComponent)
    }
    
    private func saveToDisk(image: UIImage, url: URL) {
        guard let path = cachePath(for: url),
              let data = image.jpegData(compressionQuality: 0.9) else { return }
        try? data.write(to: path)
    }
    
    private func loadFromDisk(url: URL) -> UIImage? {
        guard let path = cachePath(for: url),
              let data = try? Data(contentsOf: path) else { return nil }
        return UIImage(data: data)
    }
}
