package com.escom.practica3moviles.data.local.dao
import androidx.room.*
import com.practica3moviles.data.local.entities.FavoriteEntity
import com.practica3moviles.data.local.entities.RecentFileEntity
import com.practica3moviles.data.local.entities.ThumbnailCacheEntity
import kotlinx.coroutines.flow.Flow

/**
* DAO para gestionar el caché de miniaturas
*/

@Dao
interface ThumbnailCacheDao {

    /**
     * Obtiene una miniatura del caché
     */
    @Query("SELECT * FROM thumbnail_cache WHERE filePath = :filePath")
    suspend fun getThumbnail(filePath: String): ThumbnailCacheEntity?

    /**
     * Verifica si una miniatura es válida (el archivo no ha cambiado)
     */
    @Query("""
        SELECT EXISTS(
            SELECT 1 FROM thumbnail_cache 
            WHERE filePath = :filePath 
            AND fileModifiedDate = :modifiedDate
            AND fileSize = :fileSize
        )
    """)
    suspend fun isThumbnailValid(
        filePath: String,
        modifiedDate: Long,
        fileSize: Long
    ): Boolean

    /**
     * Inserta o actualiza una miniatura en caché
     */
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertThumbnail(thumbnail: ThumbnailCacheEntity)

    /**
     * Elimina una miniatura del caché
     */
    @Query("DELETE FROM thumbnail_cache WHERE filePath = :filePath")
    suspend fun deleteThumbnail(filePath: String)

    /**
     * Elimina miniaturas más antiguas de X días
     */
    @Query("DELETE FROM thumbnail_cache WHERE createdDate < :timestamp")
    suspend fun deleteOlderThan(timestamp: Long)

    /**
     * Elimina todas las miniaturas en caché
     */
    @Query("DELETE FROM thumbnail_cache")
    suspend fun deleteAllThumbnails()

    /**
     * Obtiene el tamaño total del caché
     */
    @Query("SELECT COUNT(*) FROM thumbnail_cache")
    suspend fun getCacheSize(): Int
}