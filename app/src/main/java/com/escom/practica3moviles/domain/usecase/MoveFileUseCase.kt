package com.escom.practica3moviles.domain.usecase

import com.escom.practica3moviles.domain.model.FileItem
import com.escom.practica3moviles.domain.repository.*
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject
/**
 * Caso de uso para mover archivo
 */
class MoveFileUseCase @Inject constructor(
    private val fileRepository: FileRepository
) {
    suspend operator fun invoke(
        sourcePath: String,
        destinationPath: String
    ): Result<FileItem> {
        return fileRepository.moveFile(sourcePath, destinationPath)
    }
}