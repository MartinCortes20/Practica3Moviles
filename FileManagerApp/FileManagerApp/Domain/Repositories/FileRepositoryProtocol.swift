//
//  FileRepositoryProtocol.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 17/10/25.
//

import Foundation

public protocol FileRepositoryProtocol {
    func getContents(of path: String) throws -> [FileItem]
    func createFolder(at path: String, name: String) throws
    func deleteItem(at path: String) throws
    func moveItem(from sourcePath: String, to destinationPath: String) throws
    func copyItem(from sourcePath: String, to destinationPath: String) throws
    func renameItem(at path: String, newName: String) throws
    func searchItems(query: String, in path: String) throws -> [FileItem]
}
