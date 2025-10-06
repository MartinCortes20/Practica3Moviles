package com.escom.practica3moviles.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.TypeConverter
import com.practica3moviles.domain.model.FileItem
import java.util.Date
/**
 * Entidad de Room para almacenar historial de archivos recientes
 */
@Entity(tableName = "recent_files")
data class RecentFileEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,                    // ID autogenerado
    val path: String,                    // Ruta del archivo
    val name: String,                    // Nombre del archivo
    val isDirectory: Boolean,            // True si es directorio
    val size: Long,                      // Tamaño en bytes
    val extension: String,               // Extensión del archivo
    val lastAccessedDate: Long,          // Timestamp del último acceso
    val accessCount: Int = 1             // Contador de accesos
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
        fun fromDomain(fileItem: FileItem): RecentFileEntity {
            return RecentFileEntity(
                path = fileItem.path,
                name = fileItem.name,
                isDirectory = fileItem.isDirectory,
                size = fileItem.size,
                extension = fileItem.extension,
                lastAccessedDate = System.currentTimeMillis()
            )
        }
    }
}