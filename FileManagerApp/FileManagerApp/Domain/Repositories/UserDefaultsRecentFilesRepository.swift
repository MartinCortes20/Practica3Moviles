//
//  UserDefaultsRecentFilesRepository.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 17/10/25.
//

import Foundation

public final class UserDefaultsRecentFilesRepository: RecentFilesRepositoryProtocol {
    private let userDefaults: UserDefaults
    private let recentFilesKey = "recent_files"
    private let maxRecentFiles = 20
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        print("🕒 RecentFilesRepository inicializado")
    }
    
    public func addRecentFile(_ fileItem: FileItem) throws {
        print("📝 Intentando agregar a recientes: \(fileItem.name)")
        print("📁 Path: \(fileItem.path)")
        
        var recentFiles = try getRecentFiles(limit: maxRecentFiles)
        print("📊 Recientes actuales: \(recentFiles.count)")
        
        // Remover si ya existe
        recentFiles.removeAll { $0.path == fileItem.path }
        
        // Agregar al inicio
        recentFiles.insert(fileItem, at: 0)
        
        // Mantener solo el límite máximo
        if recentFiles.count > maxRecentFiles {
            recentFiles = Array(recentFiles.prefix(maxRecentFiles))
        }
        
        try saveRecentFiles(recentFiles)
        print("✅ Agregado a recientes: \(fileItem.name). Total: \(recentFiles.count)")
    }
    
    public func getRecentFiles(limit: Int) throws -> [FileItem] {
        guard let data = userDefaults.data(forKey: recentFilesKey) else {
            print("📭 No hay datos de recientes en UserDefaults")
            return []
        }
        
        print("📖 Leyendo datos de recientes...")
        let decoder = JSONDecoder()
        do {
            let recentFiles = try decoder.decode([FileItem].self, from: data)
            print("✅ Recientes decodificados: \(recentFiles.count) items")
            return Array(recentFiles.prefix(limit))
        } catch {
            print("❌ ERROR CRÍTICO decodificando recientes: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            throw error
        }
    }
    
    public func clearHistory() throws {
        userDefaults.removeObject(forKey: recentFilesKey)
        let saved = userDefaults.synchronize()
        print("🧹 Historial de recientes limpiado. Sincronizado: \(saved)")
    }
    
    private func saveRecentFiles(_ files: [FileItem]) throws {
        print("💾 Intentando guardar \(files.count) recientes...")
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(files)
            print("📦 Datos codificados, tamaño: \(data.count) bytes")
            userDefaults.set(data, forKey: recentFilesKey)
            let saved = userDefaults.synchronize()
            print("💾 Recientes guardados en UserDefaults. Sincronizado: \(saved)")
        } catch {
            print("❌ ERROR CRÍTICO guardando recientes: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            throw error
        }
    }
}
