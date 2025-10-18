//
//  FilterChip.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 18/10/25.
//

import SwiftUI

public struct FilterChip: View {
    let text: String
    
    public init(text: String) {
        self.text = text
    }
    
    public var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(8)
    }
}

