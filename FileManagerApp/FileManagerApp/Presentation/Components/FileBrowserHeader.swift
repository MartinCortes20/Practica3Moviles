import SwiftUI

public struct FileBrowserHeader: View {
    @Binding var searchText: String
    @Binding var selectedFileType: FileType?
    let currentPath: String
    let onNavigateUp: () -> Void
    let onCreateFolder: () -> Void
    let onShowFilters: () -> Void
    
    @StateObject private var themeManager = ThemeManager.shared
    
    public init(
        searchText: Binding<String>,
        selectedFileType: Binding<FileType?>,
        currentPath: String,
        onNavigateUp: @escaping () -> Void,
        onCreateFolder: @escaping () -> Void,
        onShowFilters: @escaping () -> Void
    ) {
        self._searchText = searchText
        self._selectedFileType = selectedFileType
        self.currentPath = currentPath
        self.onNavigateUp = onNavigateUp
        self.onCreateFolder = onCreateFolder
        self.onShowFilters = onShowFilters
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Buscar archivos...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: onShowFilters) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(selectedFileType != nil ?
                                       themeManager.currentTheme.primaryColor : .secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Filtros activos
            if !searchText.isEmpty || selectedFileType != nil {
                HStack {
                    if !searchText.isEmpty {
                        FilterChip(text: "Búsqueda: \(searchText)") // ✅ Usa el FilterChip de FileExplorerView
                    }
                    
                    if let fileType = selectedFileType {
                        FilterChip(text: "Tipo: \(fileType.typeDescription)") // ✅ Usa el FilterChip de FileExplorerView
                    }
                    
                    Spacer()
                    
                    Button("Limpiar") {
                        searchText = ""
                        selectedFileType = nil
                    }
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
                .padding(.horizontal)
            }
            
            // Breadcrumb Navigation
            HStack {
                Button(action: onNavigateUp) {
                    Image(systemName: "arrow.up")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
                
                Text(currentPath)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Spacer()
                
                // Botón de nueva carpeta
                Button(action: onCreateFolder) {
                    Image(systemName: "folder.badge.plus")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
}

