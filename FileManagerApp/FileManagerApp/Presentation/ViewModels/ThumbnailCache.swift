//
//  ThumbnailCache.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 18/10/25.
//


// ThumbnailCache.swift
import SwiftUI

class ThumbnailCache {
    static let shared = ThumbnailCache()
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    
    private init() {
        cache.countLimit = 100 // Limitar a 100 miniaturas en caché
    }
    
    func thumbnail(for fileItem: FileItem, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage? {
        let cacheKey = "\(fileItem.path)_\(size.width)x\(size.height)" as NSString
        
        // Verificar si está en caché
        if let cachedImage = cache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // Generar miniatura
        let thumbnail = generateThumbnail(for: fileItem, size: size)
        
        // Guardar en caché
        if let thumbnail = thumbnail {
            cache.setObject(thumbnail, forKey: cacheKey)
        }
        
        return thumbnail
    }
    
    private func generateThumbnail(for fileItem: FileItem, size: CGSize) -> UIImage? {
        guard !fileItem.isDirectory else { return nil }
        
        switch fileItem.fileType {
        case .image:
            return generateImageThumbnail(path: fileItem.path, size: size)
        default:
            return nil
        }
    }
    
    private func generateImageThumbnail(path: String, size: CGSize) -> UIImage? {
        guard let image = UIImage(contentsOfFile: path) else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}
