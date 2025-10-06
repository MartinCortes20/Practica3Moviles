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
 * Implementación del repositorio de miniaturas
 */
class ThumbnailRepositoryImpl @Inject constructor(
    @ApplicationContext private val context: Context,
    private val thumbnailCacheDao: ThumbnailCacheDao
) : ThumbnailRepository {

    // Directorio para almacenar miniaturas
    private val thumbnailDir: File by lazy {
        File(context.cacheDir, "thumbnails").apply {
            if (!exists()) mkdirs()
        }
    }

    override suspend fun getThumbnail(fileItem: FileItem): Result<String> {
        return withContext(Dispatchers.IO) {
            try {
                val file = File(fileItem.path)

                // Verificar si la miniatura en caché es válida
                val cached = thumbnailCacheDao.getThumbnail(fileItem.path)
                if (cached != null) {
                    val isValid = thumbnailCacheDao.isThumbnailValid(
                        fileItem.path,
                        file.lastModified(),
                        file.length()
                    )

                    if (isValid && File(cached.thumbnailPath).exists()) {
                        return@withContext Result.success(cached.thumbnailPath)
                    }
                }

                // Generar nueva miniatura
                val thumbnailPath = generateThumbnail(file)

                if (thumbnailPath != null) {
                    // Guardar en caché
                    val entity = ThumbnailCacheEntity(
                        filePath = fileItem.path,
                        thumbnailPath = thumbnailPath,
                        createdDate = System.currentTimeMillis(),
                        fileSize = file.length(),
                        fileModifiedDate = file.lastModified()
                    )
                    thumbnailCacheDao.insertThumbnail(entity)

                    Result.success(thumbnailPath)
                } else {
                    Result.failure(Exception("No se pudo generar miniatura"))
                }
            } catch (e: Exception) {
                Result.failure(Exception("Error al obtener miniatura: ${e.message}"))
            }
        }
    }

    override suspend fun clearOldCache(daysOld: Int): Result<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                val timestamp = System.currentTimeMillis() -
                        TimeUnit.DAYS.toMillis(daysOld.toLong())

                // Obtener miniaturas antiguas antes de eliminarlas de la BD
                val oldThumbnails = thumbnailCacheDao.getThumbnail("")

                // Eliminar de la base de datos
                thumbnailCacheDao.deleteOlderThan(timestamp)

                // Eliminar archivos físicos
                thumbnailDir.listFiles()?.forEach { file ->
                    if (file.lastModified() < timestamp) {
                        file.delete()
                    }
                }

                Result.success(true)
            } catch (e: Exception) {
                Result.failure(Exception("Error al limpiar caché: ${e.message}"))
            }
        }
    }

    override suspend fun clearAllCache(): Result<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                // Eliminar de la base de datos
                thumbnailCacheDao.deleteAllThumbnails()

                // Eliminar archivos físicos
                thumbnailDir.listFiles()?.forEach { it.delete() }

                Result.success(true)
            } catch (e: Exception) {
                Result.failure(Exception("Error al limpiar caché: ${e.message}"))
            }
        }
    }

    /**
     * Genera una miniatura para un archivo de imagen
     */
    private fun generateThumbnail(file: File): String? {
        if (!file.exists() || !file.canRead()) return null

        // Solo generar miniaturas para imágenes
        val extension = file.extension.lowercase()
        if (extension !in listOf("jpg", "jpeg", "png", "bmp", "webp")) {
            return null
        }

        try {
            // Decodificar imagen con opciones para reducir memoria
            val options = BitmapFactory.Options().apply {
                inJustDecodeBounds = true
            }
            BitmapFactory.decodeFile(file.absolutePath, options)

            // Calcular factor de escala
            val targetSize = 256 // Tamaño de miniatura
            val scaleFactor = Math.min(
                options.outWidth / targetSize,
                options.outHeight / targetSize
            )

            // Decodificar imagen escalada
            val decodingOptions = BitmapFactory.Options().apply {
                inSampleSize = scaleFactor
            }
            val bitmap = BitmapFactory.decodeFile(file.absolutePath, decodingOptions)
                ?: return null

            // Guardar miniatura
            val thumbnailFile = File(
                thumbnailDir,
                "${file.nameWithoutExtension}_${file.lastModified()}.jpg"
            )

            FileOutputStream(thumbnailFile).use { out ->
                bitmap.compress(Bitmap.CompressFormat.JPEG, 80, out)
            }

            bitmap.recycle()

            return thumbnailFile.absolutePath
        } catch (e: Exception) {
            return null
        }
    }
}