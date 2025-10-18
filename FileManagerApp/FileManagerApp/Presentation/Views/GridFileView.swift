//
//  GridFileView.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 18/10/25.
//

import SwiftUI

// GridFileView.swift
struct GridFileView: View {
    let files: [FileItem]
    let onFileTap: (FileItem) -> Void
    let columns: [GridItem]
    
    init(files: [FileItem], onFileTap: @escaping (FileItem) -> Void, columnsCount: Int = 3) {
        self.files = files
        self.onFileTap = onFileTap
        self.columns = Array(repeating: GridItem(.flexible()), count: columnsCount)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(files) { item in
                    VStack {
                        Image(systemName: item.fileType.iconName)
                            .font(.title2)
                            .foregroundColor(ThemeManager.shared.currentTheme.primaryColor)
                            .frame(height: 40)
                        
                        Text(item.name)
                            .font(.caption)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                        
                        Text(item.isDirectory ? "Carpeta" : item.fileType.typeDescription)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 100, height: 100)
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(color: .gray.opacity(0.2), radius: 2)
                    .onTapGesture {
                        onFileTap(item)
                    }
                }
            }
            .padding()
        }
    }
}
