package com.escom.practica3moviles.data.repository

import android.os.Environment
import android.os.StatFs
import com.escom.practica3moviles.domain.model.FileItem
import com.escom.practica3moviles.domain.repository.FileRepository
import com.escom.practica3moviles.domain.repository.StorageInfo
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import javax.inject.Inject

/**
 * Implementación del repositorio de archivos
 * Capa de datos (Clean Architecture)
 */
class FileRepositoryImpl @Inject constructor() : FileRepository {

    override suspend fun getFilesInDirectory(path: String): Result<List<FileItem>> {
        return withContext(Dispatchers.IO) {
            try {
                val directory = File(path)

                // Verificar que el directorio existe y es accesible
                if (!directory.exists()) {
                    return@withContext Result.failure(
                        Exception("El directorio no existe: $path")
                    )
                }

                if (!directory.canRead()) {
                    return@withContext Result.failure(
                        Exception("No se tienen permisos para leer el directorio")
                    )
                }

                if (!directory.isDirectory) {
                    return@withContext Result.failure(
                        Exception("La ruta no es un directorio")
                    )
                }

                // Listar archivos y carpetas
                val files = directory.listFiles()?.mapNotNull { file ->
                    try {
                        FileItem.fromFile(file)
                    } catch (e: Exception) {
                        // Ignorar archivos que causan errores
                        null
                    }
                } ?: emptyList()

                // Ordenar: carpetas primero, luego archivos (alfabéticamente)
                val sortedFiles = files.sortedWith(
                    compareBy<FileItem> { !it.isDirectory }
                        .thenBy { it.name.lowercase() }
                )

                Result.success(sortedFiles)
            } catch (e: SecurityException) {
                Result.failure(Exception("Permiso denegado: ${e.message}"))
            } catch (e: Exception) {
                Result.failure(Exception("Error al leer directorio: ${e.message}"))
            }
        }
    }

    override suspend fun getFileInfo(path: String): Result<FileItem> {
        return withContext(Dispatchers.IO) {
            try {
                val file = File(path)
                if (!file.exists()) {
                    return@withContext Result.failure(
                        Exception("El archivo no existe")
                    )
                }
                Result.success(FileItem.fromFile(file))
            } catch (e: Exception) {
                Result.failure(Exception("Error al obtener información: ${e.message}"))
            }
        }
    }

    override suspend fun readTextFile(path: String): Result<String> {
        return withContext(Dispatchers.IO) {
            try {
                val file = File(path)

                if (!file.exists() || !file.canRead()) {
                    return@withContext Result.failure(
                        Exception("No se puede leer el archivo")
                    )
                }

                // Limitar tamaño de archivo a 5MB para evitar problemas de memoria
                if (file.length() > 5 * 1024 * 1024) {
                    return@withContext Result.failure(
                        Exception("El archivo es demasiado grande (máximo 5MB)")
                    )
                }

                val content = file.readText(Charsets.UTF_8)
                Result.success(content)
            } catch (e: Exception) {
                Result.failure(Exception("Error al leer archivo: ${e.message}"))
            }
        }
    }

    override suspend fun createDirectory(path: String, name: String): Result<FileItem> {
        return withContext(Dispatchers.IO) {
            try {
                val parentDir = File(path)
                if (!parentDir.exists() || !parentDir.isDirectory) {
                    return@withContext Result.failure(
                        Exception("El directorio padre no existe")
                    )
                }

                val newDir = File(parentDir, name)
                if (newDir.exists()) {
                    return@withContext Result.failure(
                        Exception("Ya existe un archivo o carpeta con ese nombre")
                    )
                }

                val success = newDir.mkdir()
                if (success) {
                    Result.success(FileItem.fromFile(newDir))
                } else {
                    Result.failure(Exception("No se pudo crear el directorio"))
                }
            } catch (e: Exception) {
                Result.failure(Exception("Error al crear directorio: ${e.message}"))
            }
        }
    }

    override suspend fun renameFile(oldPath: String, newName: String): Result<FileItem> {
        return withContext(Dispatchers.IO) {
            try {
                val oldFile = File(oldPath)
                if (!oldFile.exists()) {
                    return@withContext Result.failure(
                        Exception("El archivo no existe")
                    )
                }

                val newFile = File(oldFile.parent, newName)
                if (newFile.exists()) {
                    return@withContext Result.failure(
                        Exception("Ya existe un archivo con ese nombre")
                    )
                }

                val success = oldFile.renameTo(newFile)
                if (success) {
                    Result.success(FileItem.fromFile(newFile))
                } else {
                    Result.failure(Exception("No se pudo renombrar el archivo"))
                }
            } catch (e: Exception) {
                Result.failure(Exception("Error al renombrar: ${e.message}"))
            }
        }
    }

    override suspend fun copyFile(
        sourcePath: String,
        destinationPath: String
    ): Result<FileItem> {
        return withContext(Dispatchers.IO) {
            try {
                val sourceFile = File(sourcePath)
                val destFile = File(destinationPath)

                if (!sourceFile.exists()) {
                    return@withContext Result.failure(
                        Exception("El archivo origen no existe")
                    )
                }

                if (destFile.exists()) {
                    return@withContext Result.failure(
                        Exception("Ya existe un archivo en el destino")
                    )
                }

                // Copiar archivo
                if (sourceFile.isDirectory) {
                    copyDirectoryRecursively(sourceFile, destFile)
                } else {
                    sourceFile.copyTo(destFile, overwrite = false)
                }

                Result.success(FileItem.fromFile(destFile))
            } catch (e: Exception) {
                Result.failure(Exception("Error al copiar: ${e.message}"))
            }
        }
    }

    override suspend fun moveFile(
        sourcePath: String,
        destinationPath: String
    ): Result<FileItem> {
        return withContext(Dispatchers.IO) {
            try {
                val sourceFile = File(sourcePath)
                val destFile = File(destinationPath)

                if (!sourceFile.exists()) {
                    return@withContext Result.failure(
                        Exception("El archivo origen no existe")
                    )
                }

                if (destFile.exists()) {
                    return@withContext Result.failure(
                        Exception("Ya existe un archivo en el destino")
                    )
                }

                val success = sourceFile.renameTo(destFile)
                if (success) {
                    Result.success(FileItem.fromFile(destFile))
                } else {
                    Result.failure(Exception("No se pudo mover el archivo"))
                }
            } catch (e: Exception) {
                Result.failure(Exception("Error al mover: ${e.message}"))
            }
        }
    }

    override suspend fun deleteFile(path: String): Result<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                val file = File(path)
                if (!file.exists()) {
                    return@withContext Result.failure(
                        Exception("El archivo no existe")
                    )
                }

                val success = if (file.isDirectory) {
                    file.deleteRecursively()
                } else {
                    file.delete()
                }

                Result.success(success)
            } catch (e: Exception) {
                Result.failure(Exception("Error al eliminar: ${e.message}"))
            }
        }
    }

    override suspend fun searchFiles(
        rootPath: String,
        query: String,
        searchInContent: Boolean
    ): Flow<List<FileItem>> = flow {
        val results = mutableListOf<FileItem>()
        val queryLower = query.lowercase()

        suspend fun searchRecursively(directory: File) {
            try {
                directory.listFiles()?.forEach { file ->
                    try {
                        // Buscar por nombre
                        if (file.name.lowercase().contains(queryLower)) {
                            results.add(FileItem.fromFile(file))
                            emit(results.toList())
                        }

                        // Buscar en subdirectorios
                        if (file.isDirectory && file.canRead()) {
                            searchRecursively(file)
                        }
                    } catch (e: Exception) {
                        // Ignorar archivos que causan errores
                    }
                }
            } catch (e: Exception) {
                // Ignorar directorios que causan errores
            }
        }

        withContext(Dispatchers.IO) {
            searchRecursively(File(rootPath))
        }
    }

    override suspend fun getStorageInfo(): Result<StorageInfo> {
        return withContext(Dispatchers.IO) {
            try {
                val path = Environment.getExternalStorageDirectory()
                val stat = StatFs(path.path)

                val blockSize = stat.blockSizeLong
                val totalBlocks = stat.blockCountLong
                val availableBlocks = stat.availableBlocksLong

                val totalSpace = totalBlocks * blockSize
                val freeSpace = availableBlocks * blockSize
                val usedSpace = totalSpace - freeSpace

                Result.success(
                    StorageInfo(
                        totalSpace = totalSpace,
                        freeSpace = freeSpace,
                        usedSpace = usedSpace
                    )
                )
            } catch (e: Exception) {
                Result.failure(Exception("Error al obtener información de almacenamiento"))
            }
        }
    }

    /**
     * Función auxiliar para copiar directorios recursivamente
     */
    private fun copyDirectoryRecursively(source: File, destination: File) {
        if (source.isDirectory) {
            if (!destination.exists()) {
                destination.mkdirs()
            }

            source.listFiles()?.forEach { file ->
                val destFile = File(destination, file.name)
                if (file.isDirectory) {
                    copyDirectoryRecursively(file, destFile)
                } else {
                    file.copyTo(destFile, overwrite = false)
                }
            }
        } else {
            source.copyTo(destination, overwrite = false)
        }
    }
}