//
//  RecentFilesViewModel.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 17/10/25.
//

import SwiftUI

@MainActor
public final class RecentFilesViewModel: ObservableObject {
    @Published public var recentFiles: [FileItem] = []
    @Published public var errorMessage: String?
    
    private let recentFilesRepository: RecentFilesRepositoryProtocol
    
    public init(recentFilesRepository: RecentFilesRepositoryProtocol = UserDefaultsRecentFilesRepository()) {
        self.recentFilesRepository = recentFilesRepository
        loadRecentFiles()
    }
    
    public func loadRecentFiles() {
        do {
            recentFiles = try recentFilesRepository.getRecentFiles(limit: 20)
            print("✅ Recientes cargados: \(recentFiles.count) items")
        } catch {
            errorMessage = "Error al cargar archivos recientes: \(error.localizedDescription)"
            print("❌ Error cargando recientes: \(error)")
        }
    }
    
    public func addRecentFile(_ fileItem: FileItem) {
        do {
            try recentFilesRepository.addRecentFile(fileItem)
            loadRecentFiles() // Recargar la lista
            print("📝 Agregado a recientes: \(fileItem.name)")
        } catch {
            errorMessage = "Error al agregar archivo reciente: \(error.localizedDescription)"
            print("❌ Error agregando a recientes: \(error)")
        }
    }
    
    public func clearHistory() {
        do {
            try recentFilesRepository.clearHistory()
            loadRecentFiles() // Recargar la lista vacía
            print("🧹 Historial de recientes limpiado")
        } catch {
            errorMessage = "Error al limpiar historial: \(error.localizedDescription)"
        }
    }
}
