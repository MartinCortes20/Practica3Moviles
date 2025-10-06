package com.escom.practica3moviles.data.local.dao

import androidx.room.*
import com.practica3moviles.data.local.entities.FavoriteEntity
import com.practica3moviles.data.local.entities.RecentFileEntity
import com.practica3moviles.data.local.entities.ThumbnailCacheEntity
import kotlinx.coroutines.flow.Flow

/**
 * DAO para gestionar archivos favoritos
 */
@Dao
interface FavoriteDao {

    /**
     * Obtiene todos los favoritos ordenados por fecha de agregación
     */
    @Query("SELECT * FROM favorites ORDER BY addedDate DESC")
    fun getAllFavorites(): Flow<List<FavoriteEntity>>

    /**
     * Obtiene todos los favoritos de forma síncrona
     */
    @Query("SELECT * FROM favorites ORDER BY addedDate DESC")
    suspend fun getAllFavoritesList(): List<FavoriteEntity>

    /**
     * Verifica si un archivo está en favoritos
     */
    @Query("SELECT EXISTS(SELECT 1 FROM favorites WHERE path = :path)")
    suspend fun isFavorite(path: String): Boolean

    /**
     * Obtiene un favorito por su ruta
     */
    @Query("SELECT * FROM favorites WHERE path = :path")
    suspend fun getFavoriteByPath(path: String): FavoriteEntity?

    /**
     * Inserta un nuevo favorito
     */
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertFavorite(favorite: FavoriteEntity)

    /**
     * Elimina un favorito por su ruta
     */
    @Query("DELETE FROM favorites WHERE path = :path")
    suspend fun deleteFavoriteByPath(path: String)

    /**
     * Elimina un favorito
     */
    @Delete
    suspend fun deleteFavorite(favorite: FavoriteEntity)

    /**
     * Elimina todos los favoritos
     */
    @Query("DELETE FROM favorites")
    suspend fun deleteAllFavorites()

    /**
     * Busca favoritos por nombre
     */
    @Query("SELECT * FROM favorites WHERE name LIKE '%' || :query || '%' ORDER BY addedDate DESC")
    fun searchFavorites(query: String): Flow<List<FavoriteEntity>>
}