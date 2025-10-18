//
//  ContentView.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 16/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        //  SOLO FileExplorerView - sin NavigationView duplicado
        FileExplorerView(fileRepository: LocalFileRepository())
    }
}

#Preview {
    ContentView()
        //  ENVIRONMENT OBJECTS PARA EL PREVIEW
        .environmentObject(FavoritesViewModel())
        .environmentObject(RecentFilesViewModel())
}
