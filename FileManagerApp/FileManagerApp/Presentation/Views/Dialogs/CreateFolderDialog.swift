
import SwiftUI

public struct CreateFolderDialog: View {
    @Binding var isPresented: Bool
    @Binding var folderName: String
    let onConfirm: () async -> Void
    @State private var isCreating = false
    
    public init(isPresented: Binding<Bool>, folderName: Binding<String>, onConfirm: @escaping () async -> Void) {
        self._isPresented = isPresented
        self._folderName = folderName
        self.onConfirm = onConfirm
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Nueva Carpeta")
                .font(.headline)
            
            TextField("Nombre de la carpeta", text: $folderName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            HStack {
                Button("Cancelar") {
                    isPresented = false
                }
                .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    Task {
                        isCreating = true
                        await onConfirm()
                        isCreating = false
                    }
                }) {
                    if isCreating {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text("Crear")
                    }
                }
                .disabled(folderName.trimmingCharacters(in: .whitespaces).isEmpty || isCreating)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding(40)
    }
}
