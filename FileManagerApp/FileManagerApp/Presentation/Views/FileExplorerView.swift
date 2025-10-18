import SwiftUI
import UniformTypeIdentifiers

public struct FileExplorerView: View {
    @StateObject private var viewModel: FileExplorerViewModel
    @StateObject private var operationsVM: FileOperationsViewModel
    @StateObject private var sharingVM = FileSharingViewModel()
    
    // ✅ CAMBIAR A EnvironmentObject PARA COMPARTIR INSTANCIAS
    @EnvironmentObject private var favoritesVM: FavoritesViewModel
    @EnvironmentObject private var recentsVM: RecentFilesViewModel
    
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var selectedFile: FileItem?
    @State private var showingImagePreview = false
    @State private var showingFileDetail = false
    @State private var showingCreateFolder = false
    @State private var newFolderName = ""
    @State private var showingFilters = false
    @State private var showingFavorites = false
    @State private var showingRecents = false
    
    // ✅ INIT SIMPLIFICADO - SOLO RECIBE fileRepository
    public init(fileRepository: FileRepositoryProtocol) {
        let fileRepo = fileRepository
        _viewModel = StateObject(wrappedValue: FileExplorerViewModel(fileRepository: fileRepo))
        _operationsVM = StateObject(wrappedValue: FileOperationsViewModel(fileRepository: fileRepo))
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ✅ USAR COMPONENTE REUTILIZABLE
                FileBrowserHeader(
                    searchText: $viewModel.searchText,
                    selectedFileType: $viewModel.selectedFileType,
                    currentPath: viewModel.currentPath,
                    onNavigateUp: {
                        viewModel.navigateUp()
                    },
                    onCreateFolder: {
                        showingCreateFolder = true
                        newFolderName = ""
                    },
                    onShowFilters: {
                        showingFilters = true
                    }
                )
                
                // File List
                if viewModel.isLoading {
                    ProgressView("Cargando...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    ErrorView(error: error)
                } else if viewModel.fileItems.isEmpty {
                    EmptyStateView(isSearching: viewModel.isSearching)
                } else {
                    List {
                        ForEach(viewModel.fileItems) { item in
                            // ✅ ACTUALIZAR FileItemView PARA USAR EnvironmentObject
                            FileItemView(fileItem: item, onFileTap: { file in
                                handleItemTap(file)
                            })
                            .contextMenu {
                                FileContextMenu(
                                    fileItem: item,
                                    onRename: {
                                        operationsVM.showRenameDialog(for: item)
                                    },
                                    onDelete: {
                                        operationsVM.showDeleteConfirmation(for: item)
                                    },
                                    onShare: {
                                        sharingVM.shareFile(item)
                                    },
                                    onFavorite: {
                                        toggleFavorite(item)
                                    },
                                    isFavorite: favoritesVM.isFavorite(item)
                                )
                            }
                            .swipeActions(edge: .trailing) {
                                // Swipe para eliminar
                                Button(role: .destructive) {
                                    operationsVM.showDeleteConfirmation(for: item)
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                                
                                // Swipe para favoritos
                                Button {
                                    toggleFavorite(item)
                                } label: {
                                    Label(
                                        favoritesVM.isFavorite(item) ? "Quitar" : "Favorito",
                                        systemImage: favoritesVM.isFavorite(item) ? "star.slash" : "star"
                                    )
                                }
                                .tint(.yellow)
                            }
                            .swipeActions(edge: .leading) {
                                // Swipe para compartir
                                Button {
                                    sharingVM.shareFile(item)
                                } label: {
                                    Label("Compartir", systemImage: "square.and.arrow.up")
                                }
                                .tint(.blue)
                                
                                // Swipe para renombrar
                                Button {
                                    operationsVM.showRenameDialog(for: item)
                                } label: {
                                    Label("Renombrar", systemImage: "pencil")
                                }
                                .tint(.green)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        // Pull to refresh
                        viewModel.loadContents()
                    }
                }
            }
            .navigationTitle("Gestor De Archivos")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: {
                            showingFavorites = true
                        }) {
                            Label("Favoritos", systemImage: "star")
                        }
                        
                        Button(action: {
                            showingRecents = true
                        }) {
                            Label("Recientes", systemImage: "clock")
                        }
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showingCreateFolder = true
                            newFolderName = ""
                        }) {
                            Label("Nueva Carpeta", systemImage: "folder.badge.plus")
                        }
                        
                        Button(action: {
                            // Cambiar vista (lista/cuadrícula)
                        }) {
                            Label("Cambiar Vista", systemImage: "square.grid.2x2")
                        }
                        
                        Divider()
                        
                        ThemePickerView()
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            // Sheets y diálogos
            .sheet(isPresented: $showingCreateFolder) {
                CreateFolderDialog(
                    isPresented: $showingCreateFolder,
                    folderName: $newFolderName
                ) {
                    await createNewFolder()
                }
            }
            .sheet(isPresented: $showingFilters) {
                FileTypeFilterView(selectedFileType: $viewModel.selectedFileType)
            }
            .sheet(isPresented: $showingFavorites) {
                // ✅ PASAR LOS MISMOS VIEWMODELS COMPARTIDOS
                FavoritesView()
            }
            .sheet(isPresented: $showingRecents) {
                // ✅ PASAR LOS MISMOS VIEWMODELS COMPARTIDOS
                RecentFilesView()
            }
            .sheet(isPresented: $operationsVM.showRenameDialog) {
                if let item = operationsVM.selectedItem {
                    RenameDialog(
                        isPresented: $operationsVM.showRenameDialog,
                        newName: $operationsVM.newName,
                        itemName: item.name
                    ) {
                        await renameItem(item)
                    }
                }
            }
            .sheet(isPresented: $operationsVM.showDeleteConfirmation) {
                if let item = operationsVM.selectedItem {
                    DeleteConfirmationDialog(
                        isPresented: $operationsVM.showDeleteConfirmation,
                        itemName: item.name
                    ) {
                        await deleteItem(item)
                    }
                }
            }
            .sheet(item: $selectedFile) { file in
                if file.fileType == .image {
                    ImageViewerView(fileItem: file)
                } else {
                    FileDetailView(fileItem: file)
                }
            }
            .sheet(item: $sharingVM.shareSheetItem) { item in
                ShareSheet(activityItems: [item.url])
            }
            .alert("Error", isPresented: .constant(operationsVM.operationError != nil)) {
                Button("OK") { operationsVM.operationError = nil }
            } message: {
                Text(operationsVM.operationError ?? "")
            }
            .onChange(of: selectedFile) { file in
                if let file = file {
                    // Agregar a recientes cuando se abre un archivo
                    recentsVM.addRecentFile(file)
                }
            }
        }
        .accentColor(themeManager.currentTheme.primaryColor)
    }
    
    private func handleItemTap(_ item: FileItem) {
        print("=== 🖱️ HANDLE ITEM TAP ===")
        print("📄 Item: \(item.name)")
        print("📁 Es carpeta: \(item.isDirectory)")
        print("🎯 Tipo: \(item.fileType.typeDescription)")
        
        if item.isDirectory {
            viewModel.navigateToFolder(item)
        } else {
            selectedFile = item
            
            // ✅ CRÍTICO: Agregar a recientes
            print("📝 Llamando addRecentFile...")
            recentsVM.addRecentFile(item)
            print("📝 addRecentFile llamado")
            
            switch item.fileType {
            case .image:
                print("🖼️ Abriendo imagen...")
                showingImagePreview = true
            case .text, .document:
                print("📄 Abriendo documento...")
                showingFileDetail = true
            default:
                print("📤 Abriendo con otra app...")
                sharingVM.openInOtherApp(item)
            }
        }
    }
    
    private func createNewFolder() async {
        let success = await operationsVM.createFolder(
            at: viewModel.currentPath,
            name: newFolderName
        )
        if success {
            viewModel.loadContents()
            showingCreateFolder = false
            newFolderName = ""
        }
    }
    
    private func renameItem(_ item: FileItem) async {
        let success = await operationsVM.renameItem(item, newName: operationsVM.newName)
        if success {
            viewModel.loadContents()
            // Actualizar favoritos si es necesario
            if favoritesVM.isFavorite(item) {
                favoritesVM.refreshFavorites()
            }
        }
    }
    
    private func deleteItem(_ item: FileItem) async {
        let success = await operationsVM.deleteItem(item)
        if success {
            viewModel.loadContents()
            // Remover de favoritos si estaba ahí
            if favoritesVM.isFavorite(item) {
                favoritesVM.removeFavorite(item)
            }
        }
    }
    
    private func toggleFavorite(_ item: FileItem) {
        print("=== ⭐ TOGGLE FAVORITE ===")
        print("📄 Item: \(item.name)")
        print("🔍 Estado actual: \(favoritesVM.isFavorite(item))")
        
        if favoritesVM.isFavorite(item) {
            print("🗑️ Removiendo de favoritos...")
            favoritesVM.removeFavorite(item)
        } else {
            print("⭐ Agregando a favoritos...")
            favoritesVM.addFavorite(item)
        }
        
        print("🔍 Nuevo estado: \(favoritesVM.isFavorite(item))")
    }
}

// MARK: - Vistas actualizadas para usar EnvironmentObject

struct FavoritesView: View {
    // ✅ USAR EnvironmentObject EN LUGAR DE ObservedObject
    @EnvironmentObject private var viewModel: FavoritesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText: String = ""
    @State private var selectedFileType: FileType?
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                FileBrowserHeader(
                    searchText: $searchText,
                    selectedFileType: $selectedFileType,
                    currentPath: "Favoritos",
                    onNavigateUp: {
                        dismiss()
                    },
                    onCreateFolder: {
                        print("Crear carpeta no disponible en favoritos")
                    },
                    onShowFilters: {
                        showingFilters = true
                    }
                )
                
                Group {
                    let filteredFavorites = filterItems(viewModel.favorites)
                    
                    if filteredFavorites.isEmpty {
                        if !searchText.isEmpty || selectedFileType != nil {
                            EmptyStateView(isSearching: true)
                        } else {
                            VStack {
                                Image(systemName: "star")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary)
                                Text("No hay favoritos")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                Text("Agrega archivos a favoritos desde el menú contextual")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        }
                    } else {
                        List(filteredFavorites) { item in
                            FileItemView(fileItem: item, onFileTap: { _ in
                                // Manejar tap en favoritos
                            })
                        }
                    }
                }
            }
            .navigationTitle("Favoritos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FileTypeFilterView(selectedFileType: $selectedFileType)
            }
            .onAppear {
                // ✅ RECARGAR FAVORITOS CADA VEZ QUE APARECE LA VISTA
                viewModel.loadFavorites()
            }
        }
    }
    
    private func filterItems(_ items: [FileItem]) -> [FileItem] {
        var filtered = items
        
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        if let fileType = selectedFileType {
            filtered = filtered.filter { $0.fileType == fileType }
        }
        
        return filtered
    }
}

struct RecentFilesView: View {
    // ✅ USAR EnvironmentObject EN LUGAR DE ObservedObject
    @EnvironmentObject private var viewModel: RecentFilesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText: String = ""
    @State private var selectedFileType: FileType?
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                FileBrowserHeader(
                    searchText: $searchText,
                    selectedFileType: $selectedFileType,
                    currentPath: "Archivos Recientes",
                    onNavigateUp: {
                        dismiss()
                    },
                    onCreateFolder: {
                        print("Crear carpeta no disponible en recientes")
                    },
                    onShowFilters: {
                        showingFilters = true
                    }
                )
                
                Group {
                    let filteredRecents = filterItems(viewModel.recentFiles)
                    
                    if filteredRecents.isEmpty {
                        if !searchText.isEmpty || selectedFileType != nil {
                            EmptyStateView(isSearching: true)
                        } else {
                            VStack {
                                Image(systemName: "clock")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary)
                                Text("No hay archivos recientes")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                Text("Los archivos que abras aparecerán aquí")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        }
                    } else {
                        List(filteredRecents) { item in
                            FileItemView(fileItem: item, onFileTap: { _ in
                                // Manejar tap en recientes
                            })
                        }
                    }
                }
            }
            .navigationTitle("Recientes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Limpiar") {
                        viewModel.clearHistory()
                    }
                    .disabled(viewModel.recentFiles.isEmpty)
                }
            }
            .sheet(isPresented: $showingFilters) {
                FileTypeFilterView(selectedFileType: $selectedFileType)
            }
            .onAppear {
                // ✅ RECARGAR RECIENTES CADA VEZ QUE APARECE LA VISTA
                viewModel.loadRecentFiles()
            }
        }
    }
    
    private func filterItems(_ items: [FileItem]) -> [FileItem] {
        var filtered = items
        
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        if let fileType = selectedFileType {
            filtered = filtered.filter { $0.fileType == fileType }
        }
        
        return filtered
    }
}

// MARK: - Componentes de apoyo (sin cambios)

struct ErrorView: View {
    let error: String
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("Error")
                .font(.headline)
            Text(error)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct EmptyStateView: View {
    let isSearching: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: isSearching ? "magnifyingglass" : "folder")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(isSearching ? "No se encontraron resultados" : "Carpeta vacía")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            if !isSearching {
                Text("Usa el botón + para crear una nueva carpeta")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct FileContextMenu: View {
    let fileItem: FileItem
    let onRename: () -> Void
    let onDelete: () -> Void
    let onShare: () -> Void
    let onFavorite: () -> Void
    let isFavorite: Bool
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Group {
            Button(action: onShare) {
                Label("Compartir", systemImage: "square.and.arrow.up")
            }
            
            if !fileItem.isDirectory {
                Button(action: onFavorite) {
                    Label(
                        isFavorite ? "Quitar de favoritos" : "Agregar a favoritos",
                        systemImage: isFavorite ? "star.fill" : "star"
                    )
                }
                .foregroundColor(isFavorite ? .yellow : .primary)
            }
            
            Divider()
            
            Button(action: onRename) {
                Label("Renombrar", systemImage: "pencil")
            }
            
            Button(role: .destructive, action: onDelete) {
                Label("Eliminar", systemImage: "trash")
            }
        }
    }
}

struct FileTypeFilterView: View {
    @Binding var selectedFileType: FileType?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Filtrar por tipo") {
                    Button("Todos los tipos") {
                        selectedFileType = nil
                        dismiss()
                    }
                    .foregroundColor(selectedFileType == nil ? ThemeManager.shared.currentTheme.primaryColor : .primary)
                    
                    ForEach(FileType.allCases, id: \.self) { fileType in
                        Button(fileType.typeDescription) {
                            selectedFileType = fileType
                            dismiss()
                        }
                        .foregroundColor(selectedFileType == fileType ? ThemeManager.shared.currentTheme.primaryColor : .primary)
                    }
                }
            }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ThemePickerView: View {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Menu {
            ForEach(AppTheme.allCases, id: \.self) { theme in
                Button(theme.rawValue) {
                    themeManager.currentTheme = theme
                }
            }
        } label: {
            Image(systemName: "paintpalette")
        }
    }
}
