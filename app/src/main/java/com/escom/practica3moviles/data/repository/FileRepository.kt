package com.escom.practica3moviles.data.repository


import com.escom.practica3moviles.domain.model.FileItem
import kotlinx.coroutines.flow.Flow

/**
 * Repositorio para operaciones con el sistema de archivos
 * Pertenece a la capa de dominio (Clean Architecture)
 */
interface FileRepository {

    /**
     * Obtiene la lista de archivos de un directorio
     * @param path Ruta del directorio
     * @return Flow con resultado que contiene la lista de archivos o error
     */
    suspend fun getFilesInDirectory(path: String): Result<List<FileItem>>

    /**
     * Obtiene información de un archivo específico
     */
    suspend fun getFileInfo(path: String): Result<FileItem>

    /**
     * Lee el contenido de un archivo de texto
     */
    suspend fun readTextFile(path: String): Result<String>

    /**
     * Crea un nuevo directorio
     */
    suspend fun createDirectory(path: String, name: String): Result<FileItem>

    /**
     * Renombra un archivo o directorio
     */
    suspend fun renameFile(oldPath: String, newName: String): Result<FileItem>

    /**
     * Copia un archivo o directorio
     */
    suspend fun copyFile(sourcePath: String, destinationPath: String): Result<FileItem>

    /**
     * Mueve un archivo o directorio
     */
    suspend fun moveFile(sourcePath: String, destinationPath: String): Result<FileItem>

    /**
     * Elimina un archivo o directorio
     */
    suspend fun deleteFile(path: String): Result<Boolean>

    /**
     * Busca archivos por nombre
     */
    suspend fun searchFiles(
        rootPath: String,
        query: String,
        searchInContent: Boolean = false
    ): Flow<List<FileItem>>

    /**
     * Obtiene el espacio disponible en el dispositivo
     */
    suspend fun getStorageInfo(): Result<StorageInfo>
}