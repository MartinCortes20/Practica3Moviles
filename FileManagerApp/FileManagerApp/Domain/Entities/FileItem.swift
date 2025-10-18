//
//  FileItem.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 17/10/25.
//

import Foundation

public struct FileItem: Identifiable, Hashable, Codable {
    public let id: UUID
    public let name: String
    public let path: String
    public let size: Int64
    public let modificationDate: Date
    public let isDirectory: Bool
    public let fileType: FileType
    
    public init(id: UUID = UUID(), name: String, path: String, size: Int64, modificationDate: Date, isDirectory: Bool, fileType: FileType) {
        self.id = id
        self.name = name
        self.path = path
        self.size = size
        self.modificationDate = modificationDate
        self.isDirectory = isDirectory
        self.fileType = fileType
    }
    
    // ✅ IMPLEMENTACIÓN MANUAL DE CODABLE
    enum CodingKeys: String, CodingKey {
        case id, name, path, size, modificationDate, isDirectory, fileType
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(path, forKey: .path)
        try container.encode(size, forKey: .size)
        // Codificar Date como timestamp
        try container.encode(modificationDate.timeIntervalSince1970, forKey: .modificationDate)
        try container.encode(isDirectory, forKey: .isDirectory)
        try container.encode(fileType.rawValue, forKey: .fileType)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        path = try container.decode(String.self, forKey: .path)
        size = try container.decode(Int64.self, forKey: .size)
        // Decodificar Date desde timestamp
        let timestamp = try container.decode(TimeInterval.self, forKey: .modificationDate)
        modificationDate = Date(timeIntervalSince1970: timestamp)
        isDirectory = try container.decode(Bool.self, forKey: .isDirectory)
        let fileTypeRaw = try container.decode(String.self, forKey: .fileType)
        fileType = FileType(rawValue: fileTypeRaw) ?? .unknown
    }
}

public enum FileType: String, CaseIterable, Codable {
    case folder
    case image
    case text
    case document
    case unknown
    
    public var iconName: String {
        switch self {
        case .folder: return "folder"
        case .image: return "photo"
        case .text: return "doc.text"
        case .document: return "doc"
        case .unknown: return "questionmark.doc"
        }
    }
    
    public var typeDescription: String {
        switch self {
        case .folder: return "Carpeta"
        case .image: return "Imagen"
        case .text: return "Texto"
        case .document: return "Documento"
        case .unknown: return "Desconocido"
        }
    }
    
    public static func from(fileExtension: String) -> FileType {
        switch fileExtension.lowercased() {
        case "jpg", "jpeg", "png", "gif", "heic": return .image
        case "txt", "md", "json", "xml", "log": return .text
        case "pdf", "doc", "docx": return .document
        default: return .unknown
        }
    }
}
