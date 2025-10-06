package com.escom.practica3moviles.data.local.dao

import androidx.room.*
import com.practica3moviles.data.local.entities.FavoriteEntity
import com.practica3moviles.data.local.entities.RecentFileEntity
import com.practica3moviles.data.local.entities.ThumbnailCacheEntity
import kotlinx.coroutines.flow.Flow

/**
 * DAO para gestionar archivos recientes
 */
@Dao
interface RecentFileDao {

    /**
     * Obtiene los archivos recientes ordenados por última fecha de acceso
     * Limita a los últimos 50 archivos
     */
    @Query("SELECT * FROM recent_files ORDER BY lastAccessedDate DESC LIMIT 50")
    fun getRecentFiles(): Flow<List<RecentFileEntity>>

    /**
     * Obtiene los archivos recientes de forma síncrona
     */
    @Query("SELECT * FROM recent_files ORDER BY lastAccessedDate DESC LIMIT 50")
    suspend fun getRecentFilesList(): List<RecentFileEntity>

    /**
     * Obtiene un archivo reciente por su ruta
     */
    @Query("SELECT * FROM recent_files WHERE path = :path")
    suspend fun getRecentFileByPath(path: String): RecentFileEntity?

    /**
     * Inserta o actualiza un archivo reciente
     * Si ya existe, actualiza la fecha de acceso y el contador
     */
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertRecentFile(recentFile: RecentFileEntity)

    /**
     * Actualiza la fecha de acceso y el contador de un archivo
     */
    @Query("""
        UPDATE recent_files 
        SET lastAccessedDate = :timestamp, accessCount = accessCount + 1 
        WHERE path = :path
    """)
    suspend fun updateAccessTime(path: String, timestamp: Long)

    /**
     * Elimina un archivo reciente por su ruta
     */
    @Query("DELETE FROM recent_files WHERE path = :path")
    suspend fun deleteRecentFileByPath(path: String)

    /**
     * Elimina todos los archivos recientes
     */
    @Query("DELETE FROM recent_files")
    suspend fun deleteAllRecentFiles()

    /**
     * Elimina archivos recientes más antiguos de X días
     */
    @Query("DELETE FROM recent_files WHERE lastAccessedDate < :timestamp")
    suspend fun deleteOlderThan(timestamp: Long)

    /**
     * Obtiene los archivos más accedidos
     */
    @Query("SELECT * FROM recent_files ORDER BY accessCount DESC LIMIT 20")
    fun getMostAccessedFiles(): Flow<List<RecentFileEntity>>
}