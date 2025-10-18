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
    let onFavorite: (FileItem) -> Void  // ✅ NUEVO: Callback para favoritos
    let isFavorite: (FileItem) -> Bool  // ✅ NUEVO: Función para verificar si es favorito
    
    public init(
        fileItems: [FileItem],
        onFolderTap: @escaping (FileItem) -> Void,
        onFileTap: @escaping (FileItem) -> Void,
        onFavorite: @escaping (FileItem) -> Void,  // ✅ NUEVO
        isFavorite: @escaping (FileItem) -> Bool   // ✅ NUEVO
    ) {
        self.fileItems = fileItems
        self.onFolderTap = onFolderTap
        self.onFileTap = onFileTap
        self.onFavorite = onFavorite
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
                            onFavorite: {  // ✅ NUEVO: Pasar el callback
                                onFavorite(item)
                            },
                            isFavorite: isFavorite(item)  // ✅ NUEVO: Pasar el estado
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
