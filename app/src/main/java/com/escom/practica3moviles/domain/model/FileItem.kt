package com.escom.practica3moviles.domain.model

import java.io.File
import java.util.Date

/**
 * Modelo de dominio que representa un archivo o directorio en el sistema
 * Esta clase pertenece a la capa de dominio (Clean Architecture)
 */
data class FileItem(
    val path: String,                    // Ruta completa del archivo
    val name: String,                    // Nombre del archivo o carpeta
    val isDirectory: Boolean,            // True si es un directorio
    val size: Long,                      // Tamaño en bytes
    val lastModified: Date,              // Fecha de última modificación
    val extension: String,               // Extensión del archivo (vacío para carpetas)
    val mimeType: String,                // Tipo MIME del archivo
    val isHidden: Boolean,               // True si el archivo está oculto
    val canRead: Boolean,                // True si se puede leer
    val canWrite: Boolean,               // True si se puede escribir
    val parentPath: String               // Ruta del directorio padre
) {
    /**
     * Obtiene el tipo de archivo basado en su extensión
     */
    fun getFileType(): FileType {
        if (isDirectory) return FileType.DIRECTORY

        return when (extension.lowercase()) {
            // Archivos de texto
            "txt", "md", "log" -> FileType.TEXT

            // Archivos de código
            "json", "xml", "html", "css", "js", "kt", "java", "py" -> FileType.CODE

            // Imágenes
            "jpg", "jpeg", "png", "gif", "bmp", "webp", "svg" -> FileType.IMAGE

            // Videos
            "mp4", "avi", "mkv", "mov", "wmv", "flv", "webm" -> FileType.VIDEO

            // Audio
            "mp3", "wav", "ogg", "flac", "m4a", "aac" -> FileType.AUDIO

            // Documentos
            "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx" -> FileType.DOCUMENT

            // Archivos comprimidos
            "zip", "rar", "7z", "tar", "gz" -> FileType.ARCHIVE

            // APKs
            "apk" -> FileType.APK

            else -> FileType.UNKNOWN
        }
    }

    /**
     * Formatea el tamaño del archivo en una cadena legible
     */
    fun getFormattedSize(): String {
        if (isDirectory) return "Carpeta"

        val kb = 1024.0
        val mb = kb * 1024
        val gb = mb * 1024

        return when {
            size >= gb -> String.format("%.2f GB", size / gb)
            size >= mb -> String.format("%.2f MB", size / mb)
            size >= kb -> String.format("%.2f KB", size / kb)
            else -> "$size B"
        }
    }

    /**
     * Convierte el FileItem a un objeto File de Java
     */
    fun toFile(): File = File(path)

    companion object {
        /**
         * Factory method para crear un FileItem desde un File de Java
         */
        fun fromFile(file: File): FileItem {
            return FileItem(
                path = file.absolutePath,
                name = file.name,
                isDirectory = file.isDirectory,
                size = if (file.isDirectory) 0 else file.length(),
                lastModified = Date(file.lastModified()),
                extension = file.extension,
                mimeType = getMimeType(file),
                isHidden = file.isHidden,
                canRead = file.canRead(),
                canWrite = file.canWrite(),
                parentPath = file.parent ?: ""
            )
        }

        /**
         * Obtiene el tipo MIME de un archivo
         */
        private fun getMimeType(file: File): String {
            if (file.isDirectory) return "directory"

            return when (file.extension.lowercase()) {
                "txt" -> "text/plain"
                "md" -> "text/markdown"
                "log" -> "text/plain"
                "json" -> "application/json"
                "xml" -> "text/xml"
                "html" -> "text/html"
                "jpg", "jpeg" -> "image/jpeg"
                "png" -> "image/png"
                "gif" -> "image/gif"
                "pdf" -> "application/pdf"
                "zip" -> "application/zip"
                "mp4" -> "video/mp4"
                "mp3" -> "audio/mpeg"
                else -> "application/octet-stream"
            }
        }
    }
}

/**
 * Enum que define los tipos de archivos soportados
 */
enum class FileType {
    DIRECTORY,
    TEXT,
    CODE,
    IMAGE,
    VIDEO,
    AUDIO,
    DOCUMENT,
    ARCHIVE,
    APK,
    UNKNOWN
}