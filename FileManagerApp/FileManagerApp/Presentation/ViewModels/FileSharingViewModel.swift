//
//  FileSharingViewModel.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 17/10/25.
//

import SwiftUI
import UniformTypeIdentifiers

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@MainActor
public final class FileSharingViewModel: ObservableObject {
    @Published public var shareSheetItem: ShareSheetItem?
    
    public func shareFile(_ fileItem: FileItem) {
        let fileURL = URL(fileURLWithPath: fileItem.path)
        
        guard FileManager.default.fileExists(atPath: fileItem.path) else {
            print("El archivo no existe: \(fileItem.path)")
            return
        }
        
        shareSheetItem = ShareSheetItem(url: fileURL)
    }
    
    public func openInOtherApp(_ fileItem: FileItem) {
        let fileURL = URL(fileURLWithPath: fileItem.path)
        
        guard FileManager.default.fileExists(atPath: fileItem.path) else {
            print("El archivo no existe: \(fileItem.path)")
            return
        }
        
        #if os(iOS)
        // Para iOS - abrir con otras apps
        UIApplication.shared.open(fileURL)
        #elseif os(macOS)
        // Para macOS - abrir con aplicación por defecto
        NSWorkspace.shared.open(fileURL)
        #endif
    }
}

public struct ShareSheetItem: Identifiable {
    public let id = UUID()
    public let url: URL
}

// Sheet de compartir para iOS
public struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    
    public init(activityItems: [Any], applicationActivities: [UIActivity]? = nil) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
    }
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
