package com.escom.practica3moviles.domain.usecase

import com.escom.practica3moviles.domain.model.FileItem
import com.escom.practica3moviles.domain.repository.*
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject
/**
 * Caso de uso para renombrar archivo
 */
class RenameFileUseCase @Inject constructor(
    private val fileRepository: FileRepository
) {
    suspend operator fun invoke(filePath: String, newName: String): Result<FileItem> {
        // Validar nombre
        if (newName.isBlank()) {
            return Result.failure(Exception("El nombre no puede estar vacío"))
        }

        if (newName.contains("/") || newName.contains("\\")) {
            return Result.failure(Exception("El nombre contiene caracteres inválidos"))
        }

        return fileRepository.renameFile(filePath, newName)
    }
}