//
//  UserDefaultsFavoritesRepository.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 17/10/25.
//

import Foundation

public final class UserDefaultsFavoritesRepository: FavoritesRepositoryProtocol {
    private let userDefaults: UserDefaults
    private let favoritesKey = "favorite_files"
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        print("🎯 FavoritesRepository inicializado")
    }
    
    public func addFavorite(_ fileItem: FileItem) throws {
        print("⭐ Intentando agregar favorito: \(fileItem.name)")
        print("📁 Path: \(fileItem.path)")
        
        var favorites = try getFavorites()
        print("📊 Favoritos actuales: \(favorites.count)")
        
        // Evitar duplicados
        if !favorites.contains(where: { $0.path == fileItem.path }) {
            favorites.append(fileItem)
            print("➕ Agregando nuevo favorito...")
            try saveFavorites(favorites)
            print("✅ Favorito agregado exitosamente")
        } else {
            print("⚠️ Favorito ya existe, no se agrega duplicado")
        }
    }
    
    public func removeFavorite(_ fileItem: FileItem) throws {
        print("🗑️ Intentando remover favorito: \(fileItem.name)")
        var favorites = try getFavorites()
        let initialCount = favorites.count
        favorites.removeAll { $0.path == fileItem.path }
        
        if favorites.count < initialCount {
            try saveFavorites(favorites)
            print("✅ Favorito removido exitosamente")
        } else {
            print("⚠️ Favorito no encontrado para remover")
        }
    }
    
    public func getFavorites() throws -> [FileItem] {
        guard let data = userDefaults.data(forKey: favoritesKey) else {
            print("📭 No hay datos de favoritos en UserDefaults")
            return []
        }
        
        print("📖 Leyendo datos de favoritos...")
        let decoder = JSONDecoder()
        do {
            let favorites = try decoder.decode([FileItem].self, from: data)
            print("✅ Favoritos decodificados: \(favorites.count) items")
            return favorites
        } catch {
            print("❌ ERROR CRÍTICO decodificando favoritos: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            throw error
        }
    }
    
    public func isFavorite(_ fileItem: FileItem) -> Bool {
        do {
            let favorites = try getFavorites()
            let result = favorites.contains { $0.path == fileItem.path }
            print("🔍 Verificando favorito '\(fileItem.name)': \(result)")
            return result
        } catch {
            print("❌ Error verificando favorito: \(error)")
            return false
        }
    }
    
    private func saveFavorites(_ favorites: [FileItem]) throws {
        print("💾 Intentando guardar \(favorites.count) favoritos...")
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(favorites)
            print("📦 Datos codificados, tamaño: \(data.count) bytes")
            userDefaults.set(data, forKey: favoritesKey)
            let saved = userDefaults.synchronize()
            print("💾 Favoritos guardados en UserDefaults. Sincronizado: \(saved)")
        } catch {
            print("❌ ERROR CRÍTICO guardando favoritos: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            throw error
        }
    }
}
