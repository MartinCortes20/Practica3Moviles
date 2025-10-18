//
//  FileListView.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 17/10/25.
//

import SwiftUI

public struct FileListView: View {
    let fileItems: [FileItem]
    let onFolderTap: (FileItem) -> Void
    let onFileTap: (FileItem) -> Void
    let onFavorite: (FileItem) -> Void
    let onCopy: (FileItem) -> Void  // ✅ NUEVO: Callback para copiar
    let onMove: (FileItem) -> Void  // ✅ NUEVO: Callback para mover
    let isFavorite: (FileItem) -> Bool
    
    public init(
        fileItems: [FileItem],
        onFolderTap: @escaping (FileItem) -> Void,
        onFileTap: @escaping (FileItem) -> Void,
        onFavorite: @escaping (FileItem) -> Void,
        onCopy: @escaping (FileItem) -> Void,  // ✅ NUEVO
        onMove: @escaping (FileItem) -> Void,  // ✅ NUEVO
        isFavorite: @escaping (FileItem) -> Bool
    ) {
        self.fileItems = fileItems
        self.onFolderTap = onFolderTap
        self.onFileTap = onFileTap
        self.onFavorite = onFavorite
        self.onCopy = onCopy  // ✅ NUEVO
        self.onMove = onMove  // ✅ NUEVO
        self.isFavorite = isFavorite
    }
    
    public var body: some View {
        List {
            ForEach(fileItems) { item in
                FileItemView(fileItem: item, onFileTap: onFileTap)
                    .contextMenu {
                        FileContextMenu(
                            fileItem: item,
                            onRename: {
                                print("Renombrar: \(item.name)")
                            },
                            onDelete: {
                                print("Eliminar: \(item.name)")
                            },
                            onShare: {
                                print("Compartir: \(item.name)")
                            },
                            onFavorite: {
                                onFavorite(item)
                            },
                            onCopy: {  // ✅ NUEVO: Pasar el callback
                                onCopy(item)
                            },
                            onMove: {  // ✅ NUEVO: Pasar el callback
                                onMove(item)
                            },
                            isFavorite: isFavorite(item)
                        )
                    }
                    .draggable(item)
            }
        }
        .listStyle(PlainListStyle())
    }
}

// Extension para hacer FileItem draggable
extension FileItem: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.name)
    }
}
