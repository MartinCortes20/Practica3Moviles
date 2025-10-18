//
//  ImageViewerView.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 17/10/25.
//

import SwiftUI
import UIKit

public struct ImageViewerView: View {
    let fileItem: FileItem
    @State private var image: UIImage?
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var rotation: Double = 0.0
    @State private var isLoading = false
    @State private var error: String?
    
    @Environment(\.dismiss) private var dismiss // ✅ Para regresar
    
    public init(fileItem: FileItem) {
        self.fileItem = fileItem
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Cargando imagen...")
                        .foregroundColor(.white)
                } else if let error = error {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        Text("Error al cargar la imagen")
                            .foregroundColor(.white)
                        Text(error)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else if let image = image {
                    ZoomableImageView(
                        image: image,
                        scale: $scale,
                        offset: $offset,
                        rotation: $rotation
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // ✅ Botón de regreso en toolbar
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Regresar") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                // ✅ Controles de imagen en toolbar
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: rotateImage) {
                        Image(systemName: "rotate.right")
                            .foregroundColor(.white)
                    }
                    
                    Button(action: resetImage) {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.white)
                    }
                    
                    Button(action: zoomIn) {
                        Image(systemName: "plus.magnifyingglass")
                            .foregroundColor(.white)
                    }
                    
                    Button(action: zoomOut) {
                        Image(systemName: "minus.magnifyingglass")
                            .foregroundColor(.white)
                    }
                }
            }
            .overlay(controlsOverlay, alignment: .bottom) // ✅ Controles flotantes
        }
        .onAppear {
            loadImage()
        }
    }
    
    // ✅ Controles flotantes adicionales
    private var controlsOverlay: some View {
        VStack {
            HStack(spacing: 20) {
                // Zoom Out
                Button(action: zoomOut) {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.7))
                        .clipShape(Circle())
                }
                
                // Reset
                Button(action: resetImage) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.7))
                        .clipShape(Circle())
                }
                
                // Rotate
                Button(action: rotateImage) {
                    Image(systemName: "rotate.right")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.7))
                        .clipShape(Circle())
                }
                
                // Zoom In
                Button(action: zoomIn) {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.7))
                        .clipShape(Circle())
                }
            }
            
            // ✅ Indicador de zoom actual
            Text("Zoom: \(Int(scale * 100))%")
                .font(.caption)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
        }
        .padding(.bottom, 30)
    }
    
    // ✅ Gestos mejorados
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale = min(max(scale * delta, 0.5), 5.0) // Límites de zoom
            }
            .onEnded { _ in
                lastScale = 1.0
            }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }
    
    // ✅ Funciones de control
    private func zoomIn() {
        withAnimation(.easeInOut(duration: 0.2)) {
            scale = min(scale + 0.5, 5.0) // Zoom máximo 5x
        }
    }
    
    private func zoomOut() {
        withAnimation(.easeInOut(duration: 0.2)) {
            scale = max(scale - 0.5, 0.5) // Zoom mínimo 0.5x
        }
    }
    
    private func rotateImage() {
        withAnimation(.easeInOut(duration: 0.3)) {
            rotation += 90
        }
    }
    
    private func resetImage() {
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = 1.0
            offset = .zero
            lastOffset = .zero
            rotation = 0.0
            lastScale = 1.0
        }
    }
    
    private func loadImage() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let loadedImage = try await Task.detached {
                    guard let imageData = try? Data(contentsOf: URL(fileURLWithPath: fileItem.path)),
                          let uiImage = UIImage(data: imageData) else {
                        throw NSError(domain: "ImageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No se pudo cargar la imagen"])
                    }
                    return uiImage
                }.value
                
                await MainActor.run {
                    self.image = loadedImage
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

// ✅ VISTA MEJORADA: Con gestos de zoom y desplazamiento
struct ZoomableImageView: View {
    let image: UIImage
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    @Binding var rotation: Double
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(scale)
                    .offset(offset)
                    .frame(
                        width: geometry.size.width * scale,
                        height: geometry.size.height * scale
                    )
                    .gesture(
                        SimultaneousGesture(
                            magnificationGesture,
                            dragGesture
                        )
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = min(max(value, 0.5), 5.0) // Límites: 0.5x a 5x
            }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { value in
                withAnimation(.spring()) {
                    // Limitar el desplazamiento para que no se salga demasiado
                    let maxOffset: CGFloat = 200
                    offset = CGSize(
                        width: min(max(value.translation.width, -maxOffset), maxOffset),
                        height: min(max(value.translation.height, -maxOffset), maxOffset)
                    )
                }
            }
    }
}

// ✅ VISTA ALTERNATIVA: Para un control más avanzado del zoom
struct AdvancedZoomableImageView: View {
    let image: UIImage
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    @Binding var rotation: Double
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
                SimultaneousGesture(
                    magnificationGesture,
                    dragGesture
                )
            )
            .onChange(of: scale) { newValue in
                // Ajustar offset cuando se hace zoom para mantener el centro
                if scale > 1.0 {
                    let delta = scale - lastScale
                    offset.width += delta * 50 // Ajuste experimental
                    offset.height += delta * 50
                }
                lastScale = scale
            }
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                scale = min(max(scale * delta, 0.5), 5.0)
                lastScale = value
            }
            .onEnded { _ in
                lastScale = 1.0
            }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { value in
                withAnimation(.spring()) {
                    offset = value.translation
                }
            }
    }
}
