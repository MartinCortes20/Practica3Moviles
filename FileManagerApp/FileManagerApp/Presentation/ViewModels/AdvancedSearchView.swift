//
//  AdvancedSearchView.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 18/10/25.
//

import SwiftUICore
import SwiftUI

struct AdvancedSearchView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: FileExplorerViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section("Búsqueda por nombre") {
                    TextField("Nombre del archivo", text: $viewModel.searchText)
                }
                
                Section("Filtrar por tipo") {
                    Picker("Tipo de archivo", selection: $viewModel.selectedFileType) {
                        Text("Todos los tipos").tag(FileType?.none)
                        ForEach(FileType.allCases, id: \.self) { fileType in
                            Text(fileType.typeDescription).tag(FileType?.some(fileType))
                        }
                    }
                }
                
                Section("Filtrar por fecha") {
                    Toggle("Usar filtro de fecha", isOn: $viewModel.useDateFilter)
                    
                    if viewModel.useDateFilter {
                        DatePicker("Desde",
                                 selection: Binding(
                                    get: { viewModel.startDate ?? Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date() },
                                    set: { viewModel.startDate = $0 }
                                 ),
                                 displayedComponents: .date)
                        
                        DatePicker("Hasta",
                                 selection: Binding(
                                    get: { viewModel.endDate ?? Date() },
                                    set: { viewModel.endDate = $0 }
                                 ),
                                 displayedComponents: .date)
                    }
                }
                
                Section {
                    Button("Limpiar todos los filtros", role: .destructive) {
                        viewModel.clearAllFilters()
                    }
                }
            }
            .navigationTitle("Búsqueda Avanzada")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Aplicar") {
                        viewModel.performAdvancedSearch()
                        isPresented = false
                    }
                }
            }
        }
    }
}
