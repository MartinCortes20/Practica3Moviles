//
//  DeleteConfirmationDialog.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 17/10/25.
//
import SwiftUI

public struct DeleteConfirmationDialog: View {
    @Binding var isPresented: Bool
    let itemName: String
    let onConfirm: () async -> Void
    @State private var isDeleting = false
    
    public init(isPresented: Binding<Bool>, itemName: String, onConfirm: @escaping () async -> Void) {
        self._isPresented = isPresented
        self.itemName = itemName
        self.onConfirm = onConfirm
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text("Eliminar \"\(itemName)\"")
                .font(.headline)
            
            Text("Esta acción no se puede deshacer. ¿Estás seguro de que quieres eliminar este elemento?")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack {
                Button("Cancelar") {
                    isPresented = false
                }
                .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    Task {
                        isDeleting = true
                        await onConfirm()
                        isDeleting = false
                    }
                }) {
                    if isDeleting {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text("Eliminar")
                            .foregroundColor(.red)
                    }
                }
                .disabled(isDeleting)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding(40)
    }
}
