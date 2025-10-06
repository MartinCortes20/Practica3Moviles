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
 * Implementación del repositorio de archivos recientes
 */
class RecentFileRepositoryImpl @Inject constructor(
    private val recentFileDao: RecentFileDao
) : RecentFileRepository {

    override fun getRecentFiles(): Flow<List<FileItem>> {
        return recentFileDao.getRecentFiles().map { entities ->
            entities.mapNotNull { entity ->
                try {
                    // Verificar que el archivo aún existe
                    val file = File(entity.path)
                    if (file.exists()) {
                        entity.toDomain()
                    } else {
                        // Eliminar del historial si el archivo ya no existe
                        recentFileDao.deleteRecentFileByPath(entity.path)
                        null
                    }
                } catch (e: Exception) {
                    null
                }
            }
        }
    }

    override suspend fun addRecentFile(fileItem: FileItem): Result<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                // Verificar si ya existe
                val existing = recentFileDao.getRecentFileByPath(fileItem.path)

                if (existing != null) {
                    // Actualizar fecha de acceso y contador
                    recentFileDao.updateAccessTime(
                        fileItem.path,
                        System.currentTimeMillis()
                    )
                } else {
                    // Insertar nuevo registro
                    val entity = RecentFileEntity.fromDomain(fileItem)
                    recentFileDao.insertRecentFile(entity)
                }

                Result.success(true)
            } catch (e: Exception) {
                Result.failure(Exception("Error al agregar a recientes: ${e.message}"))
            }
        }
    }

    override suspend fun removeRecentFile(path: String): Result<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                recentFileDao.deleteRecentFileByPath(path)
                Result.success(true)
            } catch (e: Exception) {
                Result.failure(Exception("Error al eliminar de recientes: ${e.message}"))
            }
        }
    }

    override suspend fun clearRecentFiles(): Result<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                recentFileDao.deleteAllRecentFiles()
                Result.success(true)
            } catch (e: Exception) {
                Result.failure(Exception("Error al limpiar recientes: ${e.message}"))
            }
        }
    }

    override fun getMostAccessedFiles(): Flow<List<FileItem>> {
        return recentFileDao.getMostAccessedFiles().map { entities ->
            entities.map { it.toDomain() }
        }
    }
}