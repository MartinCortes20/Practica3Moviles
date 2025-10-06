package com.escom.practica3moviles.domain.usecase

import com.escom.practica3moviles.domain.model.FileItem
import com.escom.practica3moviles.domain.repository.*
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject
/**
 * Caso de uso para leer archivo de texto
 */
class ReadTextFileUseCase @Inject constructor(
    private val fileRepository: FileRepository
) {
    suspend operator fun invoke(filePath: String): Result<String> {
        return fileRepository.readTextFile(filePath)
    }
}