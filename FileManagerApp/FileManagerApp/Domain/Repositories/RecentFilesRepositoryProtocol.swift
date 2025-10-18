//
//  RecentFilesRepositoryProtocol.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 17/10/25.
//

import Foundation

public protocol RecentFilesRepositoryProtocol {
    func addRecentFile(_ fileItem: FileItem) throws
    func getRecentFiles(limit: Int) throws -> [FileItem]
    func clearHistory() throws
}
