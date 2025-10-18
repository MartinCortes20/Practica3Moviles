//
//  FileManagerAppApp.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 16/10/25.
//

import SwiftUI

@main
struct FileManagerAppApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var favoritesVM = FavoritesViewModel()
    @StateObject private var recentsVM = RecentFilesViewModel()
    
    var body: some Scene {
        WindowGroup {
            // ✅ SOLO UNA VISTA PRINCIPAL - ELIMINAR ContentView()
            FileExplorerView(fileRepository: LocalFileRepository())
                .preferredColorScheme(.light)
                .accentColor(themeManager.currentTheme.primaryColor)
                // ✅ MOVER environmentObject AQUÍ
                .environmentObject(favoritesVM)
                .environmentObject(recentsVM)
        }
    }
}
