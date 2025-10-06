package com.escom.practica3moviles.data.local.database

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.escom.practica3moviles.data.local.dao.FavoriteDao
import com.escom.practica3moviles.data.local.dao.RecentFileDao
import com.escom.practica3moviles.data.local.dao.ThumbnailCacheDao
import com.escom.practica3moviles.data.local.entities.Converters
import com.escom.practica3moviles.data.local.entities.FavoriteEntity
import com.escom.practica3moviles.data.local.entities.RecentFileEntity
import com.escom.practica3moviles.data.local.entities.ThumbnailCacheEntity

/**
 * Base de datos principal de la aplicación usando Room
 * Implementa el patrón Singleton para garantizar una única instancia
 */
@Database(
    entities = [
        FavoriteEntity::class,
        RecentFileEntity::class,
        ThumbnailCacheEntity::class
    ],
    version = 1,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class FileManagerDatabase : RoomDatabase() {

    // DAOs abstractos que Room implementará automáticamente
    abstract fun favoriteDao(): FavoriteDao
    abstract fun recentFileDao(): RecentFileDao
    abstract fun thumbnailCacheDao(): ThumbnailCacheDao

    companion object {
        // Nombre de la base de datos
        private const val DATABASE_NAME = "file_manager_database"

        // Instancia singleton de la base de datos
        @Volatile
        private var INSTANCE: FileManagerDatabase? = null

        /**
         * Obtiene la instancia de la base de datos
         * Usa Double-Check Locking para thread-safety
         */
        fun getDatabase(context: Context): FileManagerDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    FileManagerDatabase::class.java,
                    DATABASE_NAME
                )
                    // Estrategias de migración si cambia la estructura
                    .fallbackToDestructiveMigration()
                    // Callback para operaciones al crear la BD
                    .addCallback(object : RoomDatabase.Callback() {
                        override fun onCreate(db: androidx.sqlite.db.SupportSQLiteDatabase) {
                            super.onCreate(db)
                            // Aquí se pueden ejecutar operaciones iniciales
                        }
                    })
                    .build()
                INSTANCE = instance
                instance
            }
        }

        /**
         * Limpia la instancia de la base de datos (útil para testing)
         */
        fun clearInstance() {
            INSTANCE = null
        }
    }
}