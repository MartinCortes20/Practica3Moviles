package com.escom.practica3moviles.domain.usecase

import com.escom.practica3moviles.domain.model.FileItem
import com.escom.practica3moviles.domain.repository.*
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

/**
 * Caso de uso para obtener archivos de un directorio
 */
class GetFilesUseCase @Inject constructor(
    private val fileRepository: FileRepository
) {
    suspend operator fun invoke(path: String): Result<List<FileItem>> {
        return fileRepository.getFilesInDirectory(path)
    }
}