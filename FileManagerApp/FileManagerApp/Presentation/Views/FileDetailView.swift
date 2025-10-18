//
//  FileDetailView.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 17/10/25.
//

import SwiftUI

public struct FileDetailView: View {
    let fileItem: FileItem
    @StateObject private var themeManager = ThemeManager.shared
    @State private var fileContent: String?
    @State private var isLoadingContent = false
    
    public init(fileItem: FileItem) {
        self.fileItem = fileItem
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Image(systemName: fileItem.fileType.iconName)
                        .font(.largeTitle)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    
                    VStack(alignment: .leading) {
                        Text(fileItem.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(fileItem.isDirectory ? "Carpeta" : "Archivo")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Metadata
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 16) {
                    DetailRow(title: "Ruta", value: fileItem.path)
                    DetailRow(title: "Tamaño", value: fileItem.size.formattedByteCount())
                    DetailRow(title: "Modificado", value: fileItem.modificationDate.formattedDate())
                    DetailRow(title: "Tipo", value: fileItem.fileType.description)
                }
                
                // Preview para archivos de texto
                if fileItem.fileType == .text {
                    TextFilePreviewView(fileItem: fileItem)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Detalles")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .lineLimit(2)
        }
    }
}

// Extensiones de ayuda
extension Int64 {
    func formattedByteCount() -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: self)
    }
}

extension Date {
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

extension FileType {
    var description: String {
        switch self {
        case .folder: return "Carpeta"
        case .image: return "Imagen"
        case .text: return "Texto"
        case .document: return "Documento"
        case .unknown: return "Desconocido"
        }
    }
}
