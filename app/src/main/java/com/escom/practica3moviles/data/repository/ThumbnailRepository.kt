package com.escom.practica3moviles.data.repository

import com.practica3moviles.domain.model.FileItem
import kotlinx.coroutines.flow.Flow


/**
 * Repositorio para gestionar el caché de miniaturas
 */
interface ThumbnailRepository {

    /**
     * Obtiene la miniatura de un archivo (genera si no existe)
     */
    suspend fun getThumbnail(fileItem: FileItem): Result<String>

    /**
     * Limpia el caché de miniaturas antiguas
     */
    suspend fun clearOldCache(daysOld: Int): Result<Boolean>

    /**
     * Limpia todo el caché
     */
    suspend fun clearAllCache(): Result<Boolean>
}

/**
 * Data class para información de almacenamiento
 */
data class StorageInfo(
    val totalSpace: Long,
    val freeSpace: Long,
    val usedSpace: Long
) {
    fun getUsedPercentage(): Float {
        return if (totalSpace > 0) {
            (usedSpace.toFloat() / totalSpace.toFloat()) * 100
        } else 0f
    }