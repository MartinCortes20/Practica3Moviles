package com.escom.practica3moviles.data.repository

import com.practica3moviles.domain.model.FileItem
import kotlinx.coroutines.flow.Flow
/**
 * Repositorio para gestionar favoritos
 */
interface FavoriteRepository {

    /**
     * Obtiene todos los favoritos
     */
    fun getAllFavorites(): Flow<List<FileItem>>

    /**
     * Verifica si un archivo es favorito
     */
    suspend fun isFavorite(path: String): Boolean

    /**
     * Agrega un archivo a favoritos
     */
    suspend fun addFavorite(fileItem: FileItem): Result<Boolean>

    /**
     * Elimina un archivo de favoritos
     */
    suspend fun removeFavorite(path: String): Result<Boolean>

    /**
     * Busca en favoritos
     */
    fun searchFavorites(query: String): Flow<List<FileItem>>
}