
import SwiftUI

public struct RenameDialog: View {
    @Binding var isPresented: Bool
    @Binding var newName: String
    let itemName: String
    let onConfirm: () async -> Void
    @State private var isRenaming = false
    
    public init(isPresented: Binding<Bool>, newName: Binding<String>, itemName: String, onConfirm: @escaping () async -> Void) {
        self._isPresented = isPresented
        self._newName = newName
        self.itemName = itemName
        self.onConfirm = onConfirm
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Renombrar")
                .font(.headline)
            
            Text("Renombrar \"\(itemName)\"")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextField("Nuevo nombre", text: $newName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onAppear {
                    // Seleccionar texto sin la extensión para archivos
                    if let dotIndex = itemName.lastIndex(of: ".") {
                        newName = String(itemName[..<dotIndex])
                    }
                }
            
            HStack {
                Button("Cancelar") {
                    isPresented = false
                }
                .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    Task {
                        isRenaming = true
                        await onConfirm()
                        isRenaming = false
                    }
                }) {
                    if isRenaming {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text("Renombrar")
                    }
                }
                .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty || isRenaming)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding(40)
    }
}
