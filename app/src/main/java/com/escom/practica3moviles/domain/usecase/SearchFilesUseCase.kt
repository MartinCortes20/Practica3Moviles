package com.escom.practica3moviles.domain.usecase

import com.escom.practica3moviles.domain.model.FileItem
import com.escom.practica3moviles.domain.repository.*
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject
/**
 * Caso de uso para buscar archivos
 */
class SearchFilesUseCase @Inject constructor(
    private val fileRepository: FileRepository
) {
    suspend operator fun invoke(
        rootPath: String,
        query: String,
        searchInContent: Boolean = false
    ): Flow<List<FileItem>> {
        return fileRepository.searchFiles(rootPath, query, searchInContent)
    }
}