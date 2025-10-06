package com.escom.practica3moviles.data.repository
import com.practica3moviles.domain.model.FileItem
import kotlinx.coroutines.flow.Flow


/**
 * Repositorio para gestionar archivos recientes
 */
interface RecentFileRepository {

    /**
     * Obtiene los archivos recientes
     */
    fun getRecentFiles(): Flow<List<FileItem>>

    /**
     * Agrega un archivo al historial de recientes
     */
    suspend fun addRecentFile(fileItem: FileItem): Result<Boolean>

    /**
     * Elimina un archivo del historial
     */
    suspend fun removeRecentFile(path: String): Result<Boolean>

    /**
     * Limpia el historial de recientes
     */
    suspend fun clearRecentFiles(): Result<Boolean>

    /**
     * Obtiene los archivos más accedidos
     */
    fun getMostAccessedFiles(): Flow<List<FileItem>>
}
