package com.escom.practica3moviles.domain.usecase
import com.escom.practica3moviles.domain.model.FileItem
import com.escom.practica3moviles.domain.repository.*
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

/**
 * Caso de uso para obtener información de almacenamiento
 */
class GetStorageInfoUseCase @Inject constructor(
    private val fileRepository: FileRepository
) {
    suspend operator fun invoke(): Result<StorageInfo> {
        return fileRepository.getStorageInfo()
    }
}