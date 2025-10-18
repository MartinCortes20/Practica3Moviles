import SwiftUI

public struct FileItemView: View {
    let fileItem: FileItem
    let onFileTap: (FileItem) -> Void
    
    public init(fileItem: FileItem, onFileTap: @escaping (FileItem) -> Void) {
        self.fileItem = fileItem
        self.onFileTap = onFileTap
        print("🆕 FileItemView creado para: \(fileItem.name)")
    }
    
    public var body: some View {
        // ✅ AGREGAR LOG PARA VER QUÉ SE ESTÁ RENDERIZANDO
        let _ = print("🎨 Renderizando FileItemView: \(fileItem.name) - ¿Es carpeta?: \(fileItem.isDirectory)")
        
        if fileItem.isDirectory {
            NavigationLink(destination: FolderDetailView(folder: fileItem)) {
                contentView
                    .onAppear {
                        print("📁 Carpeta renderizada: \(fileItem.name)")
                    }
            }
        } else {
            Button(action: {
                print("🟢🟢🟢 BOTÓN DE ARCHIVO PRESIONADO: \(fileItem.name)")
                print("📍 Path: \(fileItem.path)")
                print("🎯 Tipo: \(fileItem.fileType.typeDescription)")
                onFileTap(fileItem)
            }) {
                contentView
            }
            .buttonStyle(PlainButtonStyle()) // ✅ CRÍTICO: Sin esto no funciona en List
        }
    }
    
    private var contentView: some View {
        HStack(spacing: 12) {
            Image(systemName: fileItem.fileType.iconName)
                .foregroundColor(ThemeManager.shared.currentTheme.primaryColor)
                .font(.title3)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(fileItem.name)
                    .font(.body)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(fileItem.isDirectory ? "Carpeta" : "Archivo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !fileItem.isDirectory {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(fileItem.size, format: .byteCount(style: .file))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Text(fileItem.modificationDate, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .background(
            // ✅ DEBUG: Agregar color de fondo temporal para ver el área tappable
            Color.clear
        )
    }
}

// ✅ NUEVA VISTA SIMPLIFICADA: Solo para mostrar contenido de carpeta
struct FolderDetailView: View {
    let folder: FileItem
    @StateObject private var folderVM: FolderContentViewModel
    
    init(folder: FileItem) {
        self.folder = folder
        _folderVM = StateObject(wrappedValue: FolderContentViewModel(folderPath: folder.path))
    }
    
    var body: some View {
        FolderContentView(viewModel: folderVM, folderName: folder.name)
    }
}

// ✅ NUEVO ViewModel específico para contenido de carpeta
class FolderContentViewModel: ObservableObject {
    @Published var fileItems: [FileItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    let folderPath: String // ✅ CAMBIAR: de 'private' a 'let' para acceso interno
    private let fileRepository: FileRepositoryProtocol
    
    init(folderPath: String, fileRepository: FileRepositoryProtocol = LocalFileRepository()) {
        self.folderPath = folderPath
        self.fileRepository = fileRepository
        loadContents()
    }
    
    func loadContents() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let items = try await Task.detached {
                    try self.fileRepository.getContents(of: self.folderPath)
                }.value
                
                await MainActor.run {
                    self.fileItems = items
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Error loading contents: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}

// ✅ VISTA ACTUALIZADA: Recibe el ViewModel ya configurado
struct FolderContentView: View {
    @ObservedObject var viewModel: FolderContentViewModel
    let folderName: String
    
    @State private var searchText: String = ""
    @State private var selectedFileType: FileType?
    @State private var showingCreateFolder = false
    @State private var newFolderName = ""
    @State private var showingFilters = false
    @State private var selectedFile: FileItem?
    
    // ✅ NUEVO: Operations VM para esta vista
    @StateObject private var operationsVM = FileOperationsViewModel(fileRepository: LocalFileRepository())
    @StateObject private var sharingVM = FileSharingViewModel()
    @StateObject private var favoritesVM = FavoritesViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // ✅ USAR EL MISMO HEADER EN SUBCARPETAS
            FileBrowserHeader(
                searchText: $searchText,
                selectedFileType: $selectedFileType,
                currentPath: viewModel.folderPath,
                onNavigateUp: {
                    // Navegar hacia arriba - en subcarpetas esto podría cerrar la vista
                    // o podrías implementar navegación jerárquica completa
                    print("Navegando hacia arriba desde subcarpeta")
                },
                onCreateFolder: {
                    showingCreateFolder = true
                    newFolderName = ""
                },
                onShowFilters: {
                    showingFilters = true
                }
            )
            
            // File List con filtrado local
            if viewModel.isLoading {
                ProgressView("Cargando...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                CustomErrorView(error: error)
            } else {
                let filteredItems = filterItems(viewModel.fileItems)
                
                if filteredItems.isEmpty {
                    EmptyStateView(
                        isSearching: !searchText.isEmpty || selectedFileType != nil,
                        customMessage: !searchText.isEmpty || selectedFileType != nil ?
                            "No hay resultados para los filtros aplicados" : nil
                    )
                } else {
                    List(filteredItems) { item in
                        FileItemView(fileItem: item, onFileTap: { file in
                            selectedFile = file
                            print("Archivo seleccionado en subcarpeta: \(file.name)")
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
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .navigationTitle(folderName)
        .toolbar {
            // ✅ AGREGAR TOOLBAR TAMBIÉN EN SUBCARPETAS
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingCreateFolder = true
                        newFolderName = ""
                    }) {
                        Label("Nueva Carpeta", systemImage: "folder.badge.plus")
                    }
                    
                    ThemePickerView()
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingCreateFolder) {
            CreateFolderDialog(
                isPresented: $showingCreateFolder,
                folderName: $newFolderName
            ) {
                await createNewFolder()
            }
        }
        .sheet(isPresented: $showingFilters) {
            FileTypeFilterView(selectedFileType: $selectedFileType)
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
    }
    
    // ✅ FUNCIONES DE FILTRADO LOCAL
    private func filterItems(_ items: [FileItem]) -> [FileItem] {
        var filtered = items
        
        // Filtrar por texto de búsqueda
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Filtrar por tipo de archivo
        if let fileType = selectedFileType {
            filtered = filtered.filter { $0.fileType == fileType }
        }
        
        return filtered
    }
    
    private func createNewFolder() async {
        let success = await operationsVM.createFolder(
            at: viewModel.folderPath,
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
        }
    }
    
    private func deleteItem(_ item: FileItem) async {
        let success = await operationsVM.deleteItem(item)
        if success {
            viewModel.loadContents()
        }
    }
    
    private func toggleFavorite(_ item: FileItem) {
        if favoritesVM.isFavorite(item) {
            favoritesVM.removeFavorite(item)
        } else {
            favoritesVM.addFavorite(item)
        }
    }
}

// ✅ EXTENDER EmptyStateView para mensajes personalizados
extension EmptyStateView {
    init(isSearching: Bool, customMessage: String? = nil) {
        self.init(isSearching: isSearching)
        
        if let customMessage = customMessage {
            // Podrías extender la vista para aceptar mensajes personalizados
        }
    }
}

struct CustomErrorView: View {
    let error: String
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("Error al cargar")
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

struct EmptyFolderView: View {
    let folderName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Carpeta vacía")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("La carpeta \"\(folderName)\" no contiene archivos")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
