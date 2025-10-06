package com.escom.practica3moviles.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.TypeConverter
import com.escom.practica3moviles.domain.model.FileItem
import java.util.Date

/**
 * TypeConverter para Room - convierte Date a Long y viceversa
 */
class Converters {
    @TypeConverter
    fun fromTimestamp(value: Long?): Date? {
        return value?.let { Date(it) }
    }

    @TypeConverter
    fun dateToTimestamp(date: Date?): Long? {
        return date?.time
    }
}