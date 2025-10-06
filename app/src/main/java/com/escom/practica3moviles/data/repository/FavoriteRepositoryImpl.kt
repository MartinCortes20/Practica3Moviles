package com.escom.practica3moviles.data.repository

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import com.escom.practica3moviles.data.local.dao.FavoriteDao
import com.escom.practica3moviles.data.local.dao.RecentFileDao
import com.escom.practica3moviles.data.local.dao.ThumbnailCacheDao
import com.escom.practica3moviles.data.local.entities.FavoriteEntity
import com.escom.practica3moviles.data.local.entities.RecentFileEntity
import com.escom.practica3moviles.data.local.entities.ThumbnailCacheEntity
import com.escom.practica3moviles.domain.model.FileItem
import com.escom.practica3moviles.domain.repository.FavoriteRepository
import com.escom.practica3moviles.domain.repository.RecentFileRepository
import com.escom.practica3moviles.domain.repository.ThumbnailRepository
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.TimeUnit
import javax.inject.Inject

/**
 * Implementación del repositorio de favoritos
 */
class FavoriteRepositoryImpl @Inject constructor(
    private val favoriteDao: FavoriteDao
) : FavoriteRepository {

    override fun getAllFavorites(): Flow<List<FileItem>> {
        return favoriteDao.getAllFavorites().map { entities ->
            entities.mapNotNull { entity ->
                try {
                    // Verificar que el archivo aún existe
                    val file = File(entity.path)
                    if (file.exists()) {
                        entity.toDomain()
                    } else {
                        // Eliminar favorito si el archivo ya no existe
                        favoriteDao.deleteFavoriteByPath(entity.path)
                        null
                    }
                } catch (e: Exception) {
                    null
                }
            }
        }
    }

    override suspend fun isFavorite(path: String): Boolean {
        return withContext(Dispatchers.IO) {
            favoriteDao.isFavorite(path)
        }
    }

    override suspend fun addFavorite(fileItem: FileItem): Result<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                val entity = FavoriteEntity.fromDomain(fileItem)
                favoriteDao.insertFavorite(entity)
                Result.success(true)
            } catch (e: Exception) {
                Result.failure(Exception("Error al agregar a favoritos: ${e.message}"))
            }
        }
    }

    override suspend fun removeFavorite(path: String): Result<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                favoriteDao.deleteFavoriteByPath(path)
                Result.success(true)
            } catch (e: Exception) {
                Result.failure(Exception("Error al eliminar de favoritos: ${e.message}"))
            }
        }
    }

    override fun searchFavorites(query: String): Flow<List<FileItem>> {
        return favoriteDao.searchFavorites(query).map { entities ->
            entities.map { it.toDomain() }
        }
    }
}