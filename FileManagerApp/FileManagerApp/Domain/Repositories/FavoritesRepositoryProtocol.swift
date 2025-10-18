//
//  FavoritesRepositoryProtocol.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 17/10/25.
//

import Foundation

public protocol FavoritesRepositoryProtocol {
    func addFavorite(_ fileItem: FileItem) throws
    func removeFavorite(_ fileItem: FileItem) throws
    func getFavorites() throws -> [FileItem]
    func isFavorite(_ fileItem: FileItem) -> Bool
}
