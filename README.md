# 📁 FileManager App - Gestor de Archivos
<div align="center">
Una aplicación moderna de gestión de archivos desarrollada en SwiftUI con arquitectura MVVM

</div>
## 📋 Tabla de Contenidos
Características

Capturas de Pantalla

Tecnologías

Arquitectura

Instalación

Uso

Estructura del Proyecto

Contribución

Licencia

## ✨ Características
### 🗂️ Gestión de Archivos
Exploración jerárquica de directorios internos y externos

Vista dual: Lista y Cuadrícula

Información detallada: nombre, tamaño, fecha, tipo de archivo

Operaciones completas: crear, renombrar, copiar, mover, eliminar

Búsqueda avanzada por nombre, tipo y fecha

### 👁️ Visualización
Visor de imágenes con zoom, desplazamiento y rotación

Visor de texto para .txt, .md, .log, .json, .xml

Apertura externa para archivos no soportados

Miniaturas en caché para mejor rendimiento

### 🎨 Interfaz de Usuario
Temas personalizables: IPN (#6B2E5F) y ESCOM (#003D6D)

Diseño responsivo para todos los tamaños de pantalla

Navegación intuitiva con breadcrumbs

Iconos diferenciados por tipo de archivo

Modo claro/oscuro automático

### 💾 Almacenamiento Local
Historial de archivos recientes

Sistema de favoritos persistente

Búsqueda inteligente con filtros múltiples

Caché optimizado para miniaturas

## 📸 Capturas de Pantalla

<div align="center">

### Vista Principal y Navegación
<img width="280" src="https://github.com/user-attachments/assets/9c914fc3-d96b-4751-a4f0-a2eca83ac53a" alt="Vista Principal - IMG_0165" />
<img width="280" src="https://github.com/user-attachments/assets/23759d51-9f8c-4b5a-ba34-25c6c04f06d4" alt="Navegación Carpetas - IMG_0166" />
<img width="280" src="https://github.com/user-attachments/assets/7793bf92-ec86-4a3e-8af9-c4bd000a3488" alt="Contenido Carpeta - IMG_0167" />

### Vista Cuadrícula y Detalles
<img width="280" src="https://github.com/user-attachments/assets/ad110c1f-2dea-4a02-b267-8f003dd6cf66" alt="Vista Cuadrícula - IMG_0168" />
<img width="280" src="https://github.com/user-attachments/assets/613a5ce4-3ff7-4841-a1b1-d78c29371f1d" alt="Detalles Archivo - IMG_0169" />
<img width="280" src="https://github.com/user-attachments/assets/dea7f822-7cd7-4e7b-ba30-52e26117feb5" alt="Información Detallada - IMG_0170" />

### Búsqueda y Filtros
<img width="280" src="https://github.com/user-attachments/assets/a112b540-d004-4a27-acde-d73c71d91b0e" alt="Búsqueda Simple - IMG_0171" />
<img width="280" src="https://github.com/user-attachments/assets/764fbf7d-0adb-4542-86cf-c1b88b616d43" alt="Filtro por Tipo - IMG_0172" />
<img width="280" src="https://github.com/user-attachments/assets/36ca4dad-1b73-4f3d-b439-410d94f8a7d8" alt="Búsqueda Avanzada - IMG_0173" />

### Gestión de Archivos
<img width="280" src="https://github.com/user-attachments/assets/c947a482-c1e0-4a76-aa50-80d12ca88d07" alt="Menú Contextual - IMG_0174" />
<img width="280" src="https://github.com/user-attachments/assets/4f286e60-c960-4bba-8c62-3e9103a44d52" alt="Operaciones Archivo - IMG_0175" />
<img width="280" src="https://github.com/user-attachments/assets/cb6bba1f-8192-4ec0-b737-d2f0be03d38e" alt="Diálogo Renombrar - IMG_0176" />

### Visualización
<img width="280" src="https://github.com/user-attachments/assets/8af71a4c-2fc2-42dd-9626-362b143d4b00" alt="Visor de Imágenes - IMG_0177" />
<img width="280" src="https://github.com/user-attachments/assets/a62446ce-e1d6-45df-a212-13f761d4bf99" alt="Zoom Imagen - IMG_0178" />
<img width="280" src="https://github.com/user-attachments/assets/45838ca5-f75b-44f9-99f2-821694316579" alt="Visor de Texto - IMG_0179" />

### Características Avanzadas
<img width="280" src="https://github.com/user-attachments/assets/3acddebd-2a88-4b1d-a24c-919e8b56b171" alt="Favoritos - IMG_0180" />
<img width="280" src="https://github.com/user-attachments/assets/484a6622-8b0a-4150-b4b1-cced576d24d6" alt="Archivos Recientes - IMG_0181" />
<img width="280" src="https://github.com/user-attachments/assets/66ac0bdd-b2aa-46cd-85fd-73f21cfdbb8b" alt="Tema IPN - IMG_0182" />

### Personalización
<img width="280" src="https://github.com/user-attachments/assets/04913e53-d6db-4251-9cfd-084edd29afcc" alt="Tema ESCOM - IMG_0183" />
<img width="280" src="https://github.com/user-attachments/assets/1feae405-bbfa-4cc7-a03e-ef2247054caf" alt="Selector Temas - IMG_0184" />

</div>


## 🛠️ Tecnologías
Lenguaje: Swift 5.0

UI Framework: SwiftUI 3.0+

Arquitectura: MVVM (Model-View-ViewModel)

Persistencia: UserDefaults, FileManager

Mínima Versión: iOS 15.0+

Gestión de Dependencias: Swift Package Manager

## 🏗️ Arquitectura
MVVM Pattern

## 📱 View (SwiftUI)
    ├── FileExplorerView
    ├── FileItemView
    ├── FolderContentView
    └── Componentes Reutilizables

## 🔄 ViewModel (ObservableObject)
    ├── FileExplorerViewModel
    ├── FavoritesViewModel
    ├── RecentFilesViewModel
    └── FileOperationsViewModel

## 📦 Model
    ├── FileItem
    ├── FileType
    ├── Repositories
    └── Use Cases
Principios SOLID
✅ Single Responsibility: Cada ViewModel tiene una responsabilidad única

✅ Open/Closed: Fácil extensión para nuevos tipos de archivo

✅ Liskov Substitution: Repository protocol permite diferentes implementaciones

✅ Interface Segregation: Múltiples protocolos específicos

✅ Dependency Inversion: Dependencias inyectadas via protocolos

## 📥 Instalación
Requisitos
Xcode 13.0+

iOS 15.0+

Swift 5.5+

Pasos
Clona el repositorio:

bash
git clone https://github.com/MartinCortes20/Practica3Moviles
Abre el proyecto en Xcode:

bash
cd FileManagerApp
open FileManagerApp.xcodeproj
Configura el team de desarrollo en Signing & Capabilities

Compila y ejecuta (⌘ + R)

## 🚀 Uso
Navegación Básica
Abrir carpeta: Toca cualquier carpeta

Volver atrás: Usa el botón "⬆️" o desliza desde el borde

Cambiar vista: Toca el ícono de cuadrícula/lista en el toolbar

Gestión de Archivos
Crear carpeta: Menú → "Nueva Carpeta"

Renombrar: Mantén presionado → "Renombrar"

Mover/Copiar: Mantén presionado → "Mover" o "Copiar"

Eliminar: Swipe izquierdo o menú contextual

Búsqueda y Filtros
Búsqueda simple: Escribe en la barra de búsqueda

Búsqueda avanzada: Menú → "Búsqueda Avanzada"

Filtros: Por tipo de archivo o fecha de modificación

Personalización
Cambiar tema: Menú → Selector de temas

Agregar favoritos: Mantén presionado → "Agregar a favoritos"

Ver recientes: Menú → "Archivos Recientes"

## 📁 Estructura del Proyecto

FileManagerApp/
├── 📱 App/
│   ├── FileManagerApp.swift
│   └── ContentView.swift
├── 🎯 Core/
│   ├── Domain/
│   │   ├── Entities/
│   │   │   ├── FileItem.swift
│   │   │   └── FileType.swift
│   │   ├── Repositories/
│   │   │   ├── FileRepositoryProtocol.swift
│   │   │   ├── FavoritesRepositoryProtocol.swift
│   │   │   └── RecentFilesRepositoryProtocol.swift
│   │   └── UseCases/
│   │       └── GetDirectoryContentsUseCase.swift
│   └── Data/
│       ├── Repositories/
│       │   ├── LocalFileRepository.swift
│       │   ├── UserDefaultsFavoritesRepository.swift
│       │   └── UserDefaultsRecentFilesRepository.swift
│       └── Models/
├── 🎨 Presentation/
│   ├── Views/
│   │   ├── FileExplorerView.swift
│   │   ├── FileItemView.swift
│   │   ├── FolderContentView.swift
│   │   ├── GridFileView.swift
│   │   ├── ImageViewerView.swift
│   │   ├── FileDetailView.swift
│   │   └── Components/
│   │       ├── FileBrowserHeader.swift
│   │       ├── FileContextMenu.swift
│   │       └── ThemePickerView.swift
│   ├── ViewModels/
│   │   ├── FileExplorerViewModel.swift
│   │   ├── FavoritesViewModel.swift
│   │   ├── RecentFilesViewModel.swift
│   │   └── FileOperationsViewModel.swift
│   └── Theme/
│       ├── ThemeManager.swift
│       └── AppTheme.swift
├── 🛠️ Utils/
│   ├── ThumbnailCache.swift
│   ├── FileSharingViewModel.swift
│   └── Extensions/
└── 📄 Resources/
    ├── Assets.xcassets
    └── Info.plist




## 👨‍💻 Autor
Martin Francisco Cortes Buendia



## 🙏 Agradecimientos
IPN - Por los colores institucionales

ESCOM - Inspiración para el tema azul

Comunidad de SwiftUI por las mejores prácticas
