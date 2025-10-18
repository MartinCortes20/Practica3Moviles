//
//  GetDirectoryContentsUseCase.swift
//  FileManagerApp
//
//  Created by Martin Francisco Cortes Buendia on 17/10/25.
//

import Foundation

public final class GetDirectoryContentsUseCase {
    private let fileRepository: FileRepositoryProtocol
    
    public init(fileRepository: FileRepositoryProtocol) {
        self.fileRepository = fileRepository
    }
    
    public func execute(at path: String) throws -> [FileItem] {
        return try fileRepository.getContents(of: path)
    }
}
