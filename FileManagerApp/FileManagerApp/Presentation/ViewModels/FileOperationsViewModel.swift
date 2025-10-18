//
//  FileOperationsViewModel.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 17/10/25.
//

import Foundation

@MainActor
public final class FileOperationsViewModel: ObservableObject {
    private let fileRepository: FileRepositoryProtocol
    
    @Published public var operationError: String?
    @Published public var isOperationInProgress = false
    @Published public var showCreateFolderDialog = false
    @Published public var showRenameDialog = false
    @Published public var showDeleteConfirmation = false
    @Published public var selectedItem: FileItem?
    @Published public var newName: String = ""
    
    public init(fileRepository: FileRepositoryProtocol) {
        self.fileRepository = fileRepository
    }
    
    // Crear carpeta
    public func createFolder(at path: String, name: String) async -> Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            operationError = "El nombre no puede estar vacío"
            return false
        }
        
        // Validar caracteres no permitidos
        let invalidCharacters = CharacterSet(charactersIn: "/:\\?%*|\"<>")
        if name.rangeOfCharacter(from: invalidCharacters) != nil {
            operationError = "El nombre contiene caracteres no permitidos"
            return false
        }
        
        isOperationInProgress = true
        defer { isOperationInProgress = false }
        
        do {
            try await Task.detached {
                try self.fileRepository.createFolder(at: path, name: name)
            }.value
            return true
        } catch {
            operationError = "Error al crear carpeta: \(error.localizedDescription)"
            return false
        }
    }
    
    // Renombrar
    public func renameItem(_ item: FileItem, newName: String) async -> Bool {
        guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else {
            operationError = "El nombre no puede estar vacío"
            return false
        }
        
        let invalidCharacters = CharacterSet(charactersIn: "/:\\?%*|\"<>")
        if newName.rangeOfCharacter(from: invalidCharacters) != nil {
            operationError = "El nombre contiene caracteres no permitidos"
            return false
        }
        
        isOperationInProgress = true
        defer { isOperationInProgress = false }
        
        do {
            try await Task.detached {
                try self.fileRepository.renameItem(at: item.path, newName: newName)
            }.value
            return true
        } catch {
            operationError = "Error al renombrar: \(error.localizedDescription)"
            return false
        }
    }
    
    // Eliminar
    public func deleteItem(_ item: FileItem) async -> Bool {
        isOperationInProgress = true
        defer { isOperationInProgress = false }
        
        do {
            try await Task.detached {
                try self.fileRepository.deleteItem(at: item.path)
            }.value
            return true
        } catch {
            operationError = "Error al eliminar: \(error.localizedDescription)"
            return false
        }
    }
    
    // Mover
    public func moveItem(_ item: FileItem, to destinationPath: String) async -> Bool {
        isOperationInProgress = true
        defer { isOperationInProgress = false }
        
        do {
            try await Task.detached {
                let destinationURL = URL(fileURLWithPath: destinationPath).appendingPathComponent(item.name)
                try self.fileRepository.moveItem(from: item.path, to: destinationURL.path)
            }.value
            return true
        } catch {
            operationError = "Error al mover: \(error.localizedDescription)"
            return false
        }
    }
    
    // Copiar
    public func copyItem(_ item: FileItem, to destinationPath: String) async -> Bool {
        isOperationInProgress = true
        defer { isOperationInProgress = false }
        
        do {
            try await Task.detached {
                let destinationURL = URL(fileURLWithPath: destinationPath).appendingPathComponent(item.name)
                try self.fileRepository.copyItem(from: item.path, to: destinationURL.path)
            }.value
            return true
        } catch {
            operationError = "Error al copiar: \(error.localizedDescription)"
            return false
        }
    }
    
    // Diálogos
    public func showCreateFolderDialog(at path: String) {
        selectedItem = FileItem(
            name: "",
            path: path,
            size: 0,
            modificationDate: Date(),
            isDirectory: true,
            fileType: .folder
        )
        newName = ""
        showCreateFolderDialog = true
    }
    
    public func showRenameDialog(for item: FileItem) {
        selectedItem = item
        newName = item.name
        showRenameDialog = true
    }
    
    public func showDeleteConfirmation(for item: FileItem) {
        selectedItem = item
        showDeleteConfirmation = true
    }
}
