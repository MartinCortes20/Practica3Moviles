//
//  FavoritesViewModel.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 17/10/25.
//

import SwiftUI

@MainActor
public final class FavoritesViewModel: ObservableObject {
    @Published public var favorites: [FileItem] = []
    @Published public var errorMessage: String?
    
    private let favoritesRepository: FavoritesRepositoryProtocol
    
    public init(favoritesRepository: FavoritesRepositoryProtocol = UserDefaultsFavoritesRepository()) {
        self.favoritesRepository = favoritesRepository
        loadFavorites()
    }
    
    public func loadFavorites() {
        do {
            favorites = try favoritesRepository.getFavorites()
            print("✅ Favoritos cargados: \(favorites.count) items")
        } catch {
            errorMessage = "Error al cargar favoritos: \(error.localizedDescription)"
            print("❌ Error cargando favoritos: \(error)")
        }
    }
    
    public func addFavorite(_ fileItem: FileItem) {
        do {
            try favoritesRepository.addFavorite(fileItem)
            loadFavorites() // Recargar la lista
            print("⭐ Agregado a favoritos: \(fileItem.name)")
        } catch {
            errorMessage = "Error al agregar favorito: \(error.localizedDescription)"
            print("❌ Error agregando favorito: \(error)")
        }
    }
    
    public func removeFavorite(_ fileItem: FileItem) {
        do {
            try favoritesRepository.removeFavorite(fileItem)
            loadFavorites() // Recargar la lista
            print("❌ Removido de favoritos: \(fileItem.name)")
        } catch {
            errorMessage = "Error al remover favorito: \(error.localizedDescription)"
        }
    }
    
    public func isFavorite(_ fileItem: FileItem) -> Bool {
        let result = favoritesRepository.isFavorite(fileItem)
        print("🔍 ¿Es favorito \(fileItem.name)? \(result)")
        return result
    }
    
    public func refreshFavorites() {
        loadFavorites()
    }
}
