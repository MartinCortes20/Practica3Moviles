package com.escom.practica3moviles.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.TypeConverter
import com.escom.practica3moviles.domain.model.FileItem
import java.util.Date


/**
 * Entidad para almacenar miniaturas en caché
 */
@Entity(tableName = "thumbnail_cache")
data class ThumbnailCacheEntity(
    @PrimaryKey
    val filePath: String,                // Ruta del archivo (clave primaria)
    val thumbnailPath: String,           // Ruta de la miniatura generada
    val createdDate: Long,               // Timestamp de creación
    val fileSize: Long,                  // Tamaño del archivo original
    val fileModifiedDate: Long           // Fecha de modificación del archivo
)
