package com.escom.practica3moviles.domain.usecase

import com.escom.practica3moviles.domain.model.FileItem
import com.escom.practica3moviles.domain.repository.*
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject
/**
 * Caso de uso para crear un directorio
 */
class CreateDirectoryUseCase @Inject constructor(
    private val fileRepository: FileRepository
) {
    suspend operator fun invoke(parentPath: String, name: String): Result<FileItem> {
        // Validar nombre
        if (name.isBlank()) {
            return Result.failure(Exception("El nombre no puede estar vacío"))
        }

        if (name.contains("/") || name.contains("\\")) {
            return Result.failure(Exception("El nombre contiene caracteres inválidos"))
        }

        return fileRepository.createDirectory(parentPath, name)
    }
}
