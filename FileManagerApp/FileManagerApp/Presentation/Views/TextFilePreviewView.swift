//
//  TextFilePreviewView.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 17/10/25.
//

import SwiftUI

public struct TextFilePreviewView: View {
    let fileItem: FileItem
    @State private var fileContent: String?
    @State private var isLoading = false
    @State private var error: String?
    
    public init(fileItem: FileItem) {
        self.fileItem = fileItem
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text("Vista Previa")
                .font(.headline)
                .padding(.bottom, 8)
            
            if isLoading {
                ProgressView("Cargando...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if let error = error {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else if let content = fileContent {
                ScrollView {
                    Text(content)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .padding()
                }
                .frame(height: 200)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .onAppear {
            loadFileContent()
        }
    }
    
    private func loadFileContent() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let content = try await Task.detached {
                    try String(contentsOfFile: self.fileItem.path, encoding: .utf8)
                }.value
                
                await MainActor.run {
                    // Limitar a las primeras 10,000 caracteres para performance
                    self.fileContent = String(content.prefix(10000))
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
