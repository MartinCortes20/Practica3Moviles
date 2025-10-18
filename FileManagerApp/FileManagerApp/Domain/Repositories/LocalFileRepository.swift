//
//  LocalFileRepository.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 17/10/25.
//
import Foundation

public final class LocalFileRepository: FileRepositoryProtocol {
    private let fileManager: FileManager
    
    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    public func getContents(of path: String) throws -> [FileItem] {
        let url = URL(fileURLWithPath: path)
        let contents = try fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )
        
        return try contents.map { url in
            let resourceValues = try url.resourceValues(forKeys: [
                .isDirectoryKey,
                .fileSizeKey,
                .contentModificationDateKey
            ])
            
            let isDirectory = resourceValues.isDirectory ?? false
            let fileExtension = isDirectory ? "" : url.pathExtension
            let fileType: FileType = isDirectory ? .folder : .from(fileExtension: fileExtension)
            
            return FileItem(
                name: url.lastPathComponent,
                path: url.path,
                size: Int64(resourceValues.fileSize ?? 0),
                modificationDate: resourceValues.contentModificationDate ?? Date(),
                isDirectory: isDirectory,
                fileType: fileType
            )
        }.sorted { first, second in
            // Folders first, then files
            if first.isDirectory && !second.isDirectory {
                return true
            } else if !first.isDirectory && second.isDirectory {
                return false
            }
            return first.name.localizedCaseInsensitiveCompare(second.name) == .orderedAscending
        }
    }
    
    public func createFolder(at path: String, name: String) throws {
        let folderURL = URL(fileURLWithPath: path).appendingPathComponent(name)
        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
    }
    
    public func deleteItem(at path: String) throws {
        try fileManager.removeItem(atPath: path)
    }
    
    public func moveItem(from sourcePath: String, to destinationPath: String) throws {
        try fileManager.moveItem(atPath: sourcePath, toPath: destinationPath)
    }
    
    public func copyItem(from sourcePath: String, to destinationPath: String) throws {
        try fileManager.copyItem(atPath: sourcePath, toPath: destinationPath)
    }
    
    public func renameItem(at path: String, newName: String) throws {
        let url = URL(fileURLWithPath: path)
        let newURL = url.deletingLastPathComponent().appendingPathComponent(newName)
        try fileManager.moveItem(at: url, to: newURL)
    }
    
    public func searchItems(query: String, in path: String) throws -> [FileItem] {
        let allItems = try getContents(of: path)
        return allItems.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
}
