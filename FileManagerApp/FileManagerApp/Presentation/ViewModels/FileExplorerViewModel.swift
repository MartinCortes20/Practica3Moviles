//
//  FileExplorerViewModel.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 17/10/25.
//

import Foundation
import Combine

@MainActor
public final class FileExplorerViewModel: ObservableObject {
    @Published public var fileItems: [FileItem] = []
       @Published public var currentPath: String = ""
       @Published public var isLoading: Bool = false
       @Published public var errorMessage: String?
       @Published public var searchText: String = ""
       @Published public var selectedFileType: FileType?
       @Published public var isSearching: Bool = false
       
       // ✅ NUEVOS ESTADOS PARA BÚSQUEDA AVANZADA
       @Published public var startDate: Date?
       @Published public var endDate: Date?
       @Published public var useDateFilter: Bool = false
       
       private let getDirectoryContentsUseCase: GetDirectoryContentsUseCase
       private let fileRepository: FileRepositoryProtocol
       private var allFileItems: [FileItem] = []
       private var cancellables = Set<AnyCancellable>()
       
    
    public init(fileRepository: FileRepositoryProtocol) {
        self.fileRepository = fileRepository
        self.getDirectoryContentsUseCase = GetDirectoryContentsUseCase(fileRepository: fileRepository)
        
        setupSearch()
        // Start at documents directory
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
            self.currentPath = documentsPath
            loadContents()
        }
    }
    
    private func setupSearch() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.performSearch(searchText)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(_ searchText: String) {
        print("🔍 Buscando: '\(searchText)' en \(allFileItems.count) items")
        
        if searchText.isEmpty && selectedFileType == nil && !useDateFilter {
            fileItems = allFileItems
            isSearching = false
            print("✅ Todos los filtros limpiados, mostrando \(fileItems.count) items")
        } else {
            isSearching = true
            
            // ✅ APLICAR TODOS LOS FILTROS
            var filteredItems = allFileItems
            
            // Filtro por texto
            if !searchText.isEmpty {
                filteredItems = filteredItems.filter {
                    $0.name.localizedCaseInsensitiveContains(searchText)
                }
                print("✅ Filtro por texto aplicado: '\(searchText)'")
            }
            
            // Filtro por tipo
            if let fileType = selectedFileType {
                filteredItems = filteredItems.filter { $0.fileType == fileType }
                print("✅ Filtro aplicado por tipo: \(fileType.typeDescription)")
            }
            
            // ✅ NUEVO: Filtro por fecha
            if useDateFilter {
                if let startDate = startDate {
                    filteredItems = filteredItems.filter { $0.modificationDate >= startDate }
                    print("✅ Filtro por fecha desde: \(startDate)")
                }
                if let endDate = endDate {
                    filteredItems = filteredItems.filter { $0.modificationDate <= endDate }
                    print("✅ Filtro por fecha hasta: \(endDate)")
                }
            }
            
            fileItems = filteredItems
            print("✅ Búsqueda avanzada completada: \(filteredItems.count) items encontrados")
        }
    }
    
    // ✅ FUNCIÓN PARA EJECUTAR BÚSQUEDA AVANZADA
    public func performAdvancedSearch() {
        performSearch(searchText)
    }

    // ✅ FUNCIÓN PARA LIMPIAR TODOS LOS FILTROS
    public func clearAllFilters() {
        searchText = ""
        selectedFileType = nil
        useDateFilter = false
        startDate = nil
        endDate = nil
        fileItems = allFileItems
        isSearching = false
        print("🧹 Todos los filtros limpiados")
    }

    // ✅ FUNCIÓN PARA ACTUALIZAR FILTROS DE FECHA
    public func updateDateFilter(start: Date?, end: Date?, enabled: Bool) {
        startDate = start
        endDate = end
        useDateFilter = enabled
        performSearch(searchText)
        print("📅 Filtro de fecha actualizado: \(enabled ? "activado" : "desactivado")")
    }

    
    public func loadContents(at path: String? = nil) {
        let targetPath = path ?? currentPath
        isLoading = true
        errorMessage = nil
        
        print("📂 Cargando contenido de: \(targetPath)")
        
        Task {
            do {
                let items = try await Task.detached { [weak self] in
                    try self?.getDirectoryContentsUseCase.execute(at: targetPath) ?? []
                }.value
                
                await MainActor.run {
                    self.allFileItems = items
                    self.fileItems = items
                    if path != nil {
                        self.currentPath = targetPath
                    }
                    self.isLoading = false
                    
                    // ✅ RESETEAR TODOS LOS FILTROS AL NAVEGAR
                    self.searchText = ""
                    self.selectedFileType = nil
                    self.useDateFilter = false
                    self.startDate = nil
                    self.endDate = nil
                    self.isSearching = false
                    
                    print("✅ Contenido cargado: \(items.count) items, filtros reseteados")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Error loading contents: \(error.localizedDescription)"
                    self.isLoading = false
                    print("❌ Error cargando contenido: \(error)")
                }
            }
        }
    }
    
    public func filterByFileType(_ fileType: FileType?) {
        selectedFileType = fileType
        performSearch(searchText)
    }
    
    public func navigateToFolder(_ folder: FileItem) {
        guard folder.isDirectory else { return }
        print("📁 Navegando a carpeta: \(folder.name)")
        loadContents(at: folder.path)
    }
    
    public func navigateUp() {
        let url = URL(fileURLWithPath: currentPath)
        let parentURL = url.deletingLastPathComponent()
        
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path,
           parentURL.path.hasPrefix(documentsPath) || parentURL.path == "/" {
            print("⬆️ Navegando hacia arriba: \(parentURL.path)")
            loadContents(at: parentURL.path)
        }
    }
    
    func advancedSearch(name: String? = nil, fileType: FileType? = nil, startDate: Date? = nil, endDate: Date? = nil) -> [FileItem] {
        return fileItems.filter { item in
            var matches = true
            
            if let name = name, !name.isEmpty {
                matches = matches && item.name.localizedCaseInsensitiveContains(name)
            }
            
            if let fileType = fileType {
                matches = matches && item.fileType == fileType
            }
            
            if let startDate = startDate {
                matches = matches && item.modificationDate >= startDate
            }
            
            if let endDate = endDate {
                matches = matches && item.modificationDate <= endDate
            }
            
            return matches
        }
    }
}
