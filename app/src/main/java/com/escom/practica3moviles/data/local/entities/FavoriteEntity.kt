package com.escom.practica3moviles.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.practica3moviles.domain.model.FileItem

/**
 * Entidad de Room para almacenar archivos favoritos
 */
@Entity(tableName = "favorites")
data class FavoriteEntity(
    @PrimaryKey
    val path: String,                    // Ruta del archivo (clave primaria)
    val name: String,                    // Nombre del archivo
    val isDirectory: Boolean,            // True si es directorio
    val size: Long,                      // Tamaño en bytes
    val extension: String,               // Extensión del archivo
    val addedDate: Long                  // Timestamp cuando se agregó a favoritos
) {
    /**
     * Convierte la entidad a un modelo de dominio
     */
    fun toDomain(): FileItem {
        return FileItem.fromFile(java.io.File(path))
    }

    companion object {
        /**
         * Crea una entidad desde un FileItem
         */
        fun fromDomain(fileItem: FileItem): FavoriteEntity {
            return FavoriteEntity(
                path = fileItem.path,
                name = fileItem.name,
                isDirectory = fileItem.isDirectory,
                size = fileItem.size,
                extension = fileItem.extension,
                addedDate = System.currentTimeMillis()
            )
        }
    }
}