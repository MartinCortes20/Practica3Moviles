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
        
        if searchText.isEmpty {
            fileItems = allFileItems
            isSearching = false
            print("✅ Búsqueda limpiada, mostrando \(fileItems.count) items")
        } else {
            isSearching = true
            let filteredItems = allFileItems.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
            fileItems = filteredItems
            print("✅ Búsqueda completada: Encontrados \(filteredItems.count) items")
        }
        
        // Aplicar filtro de tipo si está seleccionado
        if let fileType = selectedFileType {
            fileItems = fileItems.filter { $0.fileType == fileType }
            print("✅ Filtro aplicado por tipo: \(fileType.typeDescription)")
        }
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
                    self.searchText = "" // Reset search when navigating
                    self.selectedFileType = nil // Reset filter when navigating
                    print("✅ Contenido cargado: \(items.count) items")
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
}
