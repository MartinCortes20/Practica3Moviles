//
//  ThemeManager.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 17/10/25.
//

import SwiftUI

public enum AppTheme: String, CaseIterable {
    case guinda = "Guinda"
    case azul = "Azul"
    
    var primaryColor: Color {
        switch self {
        case .guinda: return Color(red: 0.42, green: 0.18, blue: 0.37) // #6B2E5F
        case .azul: return Color(red: 0.0, green: 0.24, blue: 0.43) // #003D6D
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .guinda: return Color(red: 0.85, green: 0.75, blue: 0.85)
        case .azul: return Color(red: 0.8, green: 0.9, blue: 1.0)
        }
    }
}

public class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") public var currentTheme: AppTheme = .guinda
    
    public static let shared = ThemeManager()
    private init() {}
}
