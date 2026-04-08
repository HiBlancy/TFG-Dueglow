# ✦ DueGlow

> Aplicación móvil para el seguimiento de productos de belleza y autocuidado: gestión de caducidades, listas personalizadas, rutinas y resumen anual al estilo Spotify Wrapped.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![NestJS](https://img.shields.io/badge/NestJS-10.x-E0234E?logo=nestjs)
![MongoDB](https://img.shields.io/badge/MongoDB-7.x-47A248?logo=mongodb)
![Estado](https://img.shields.io/badge/Estado-En%20desarrollo-yellow)
![TFG](https://img.shields.io/badge/TFG-2024--2025-blue)

---

## 📋 Tabla de contenidos

- [Descripción](#-descripción)
- [Tecnologías](#-tecnologías)
- [Arquitectura](#-arquitectura)
- [Requisitos previos](#-requisitos-previos)
- [Instalación y configuración](#-instalación-y-configuración)
- [Uso](#-uso)
- [Estructura del proyecto](#-estructura-del-proyecto)
- [API Reference](#-api-reference)
- [Variables de entorno](#-variables-de-entorno)
- [Estado del proyecto](#-estado-del-proyecto)
- [Autor](#-autor)

---

## 📖 Descripción

DueGlow es una aplicación móvil orientada al mundo del autocuidado y la belleza que permite llevar un control completo de tus productos cosméticos: desde su fecha de caducidad hasta las listas de deseos, favoritos y productos ya usados. La app integra un escáner de código de barras que consulta una API externa de productos para añadirlos de forma automática, y permite también la búsqueda manual o la creación de productos personalizados.

Además de la gestión de productos, DueGlow incluye un módulo de rutinas donde el usuario puede crear y organizar sus pasos de skincare, maquillaje o haircare, con la posibilidad de hacerlas públicas para que otros usuarios las consulten. Cada mes y al final del año, la app genera un resumen visual de los productos usados (Project Pan), al estilo Spotify Wrapped.

**Funcionalidades principales:**
- 📦 Gestión de productos por categoría (skincare, bodycare, haircare, maquillaje)
- ⏰ Control de fechas de caducidad con alertas y notificaciones
- 📷 Escaneo de código de barras con integración a API de cosméticos
- 📋 Listas: tengo · quiero · favoritos · ya usados
- ✨ Project Pan — resumen mensual y anual de productos terminados
- 🧴 Módulo de rutinas con pasos, comentarios y visibilidad pública
- 🔒 Sin red social — solo se pueden ver las rutinas públicas de otros usuarios

---

## 🛠 Tecnologías

| Capa | Tecnología | Versión | Uso |
|------|-----------|---------|-----|
| **Frontend / App** | Flutter | 3.x | Aplicación móvil multiplataforma (Android / iOS) |
| **Backend** | NestJS | 10.x | API REST con arquitectura modular |
| **Base de datos** | MongoDB | 7.x | Almacenamiento de datos NoSQL |
| **ODM** | Mongoose | 8.x | Modelado de datos para MongoDB |
| **Visualización BD** | MongoDB Compass | Latest | Exploración y gestión visual de la base de datos |
| **Gestión de estado** | [Provider / Riverpod / Bloc] | x.x | Estado global en Flutter |
| **Escaneo de barras** | mobile_scanner | x.x | Lectura de códigos de barras por cámara |
| **API de cosméticos** | Open Beauty Facts / [otra] | - | Base de datos de productos por código de barras |
| **Notificaciones** | flutter_local_notifications | x.x | Alertas de caducidad de productos |
| **Autenticación** | JWT + NestJS Passport | - | Gestión de sesiones de usuario |

---

## 🏗 Arquitectura

El proyecto sigue una arquitectura **cliente-servidor** desacoplada:

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENTE (Flutter)                     │
│                                                         │
│   UI Layer ──► State Management ──► Repository Layer    │
│                                          │              │
└──────────────────────────────────────────┼──────────────┘
                                           │ HTTP / REST
                                           ▼
┌─────────────────────────────────────────────────────────┐
│                   BACKEND (NestJS)                      │
│                                                         │
│   Controllers ──► Services ──► Repositories (Mongoose)  │
│                                          │              │
└──────────────────────────────────────────┼──────────────┘
                                           │ Mongoose ODM
                                           ▼
┌─────────────────────────────────────────────────────────┐
│                  BASE DE DATOS (MongoDB)                 │
│                                                         │
│   Collections: [users] [items] [...]                    │
│   Visualización: MongoDB Compass (cualquier equipo)     │
└─────────────────────────────────────────────────────────┘
```

> Para más detalle ver [`/docs/arquitectura.md`](./docs/arquitectura.md)

---

## ✅ Requisitos previos

Antes de instalar el proyecto, asegúrate de tener instalado:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versión 3.x o superior)
- [Node.js](https://nodejs.org/) (versión 18.x o superior)
- [MongoDB](https://www.mongodb.com/try/download/community) en local **o** una cadena de conexión de [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
- [MongoDB Compass](https://www.mongodb.com/products/compass) (opcional, para visualizar los datos)
- Un emulador Android / dispositivo físico con depuración USB activada

---

## 🚀 Instalación y configuración

### 1. Clonar el repositorio

```bash
git clone https://github.com/[tu-usuario]/[nombre-repo].git
cd [nombre-repo]
```

### 2. Configurar el Backend (NestJS)

```bash
# Entrar en la carpeta del backend
cd backend

# Instalar dependencias
npm install

# Copiar el archivo de variables de entorno
cp .env.example .env

# Editar .env con tus valores (ver sección Variables de entorno)
nano .env

# Ejecutar en modo desarrollo
npm run start:dev
```

El servidor arrancará en `http://localhost:3000`

### 3. Configurar la App (Flutter)

```bash
# Volver a la raíz y entrar en la app
cd ../app

# Obtener dependencias de Flutter
flutter pub get

# Asegúrate de que tienes un emulador corriendo o un dispositivo conectado
flutter devices

# Ejecutar la app
flutter run
```

### 4. Conectar MongoDB Compass

Abre MongoDB Compass e introduce tu cadena de conexión:
```
mongodb://localhost:27017/[nombre-base-de-datos]
```
O si usas Atlas:
```
mongodb+srv://[usuario]:[password]@cluster.mongodb.net/[nombre-bd]
```

---

## 📱 Uso

[Describe aquí cómo usar la aplicación paso a paso. Puedes añadir capturas de pantalla.]

```
1. Abre la app en tu dispositivo
2. Regístrate o inicia sesión
3. [Paso 3...]
4. [Paso 4...]
```

---

## 📁 Estructura del proyecto

```
dueglow/
│
├── app/                                # Proyecto Flutter (cliente móvil)
│   ├── lib/
│   │   ├── core/                       # Configuración global, temas, constantes
│   │   │   ├── constants/              # URLs de API, colores, strings
│   │   │   ├── theme/                  # Tema visual de DueGlow
│   │   │   └── network/                # Cliente HTTP (Dio)
│   │   ├── data/                       # Modelos, repositorios, datasources
│   │   │   ├── models/                 # Product, Routine, User, ProjectPan...
│   │   │   └── repositories/
│   │   └── presentation/               # Pantallas y widgets
│   │       ├── home/
│   │       ├── products/               # Listado, detalle, añadir producto
│   │       ├── scanner/                # Escáner de código de barras
│   │       ├── routines/               # Crear y ver rutinas
│   │       ├── lists/                  # Tengo · Quiero · Favoritos · Usados
│   │       ├── project_pan/            # Resumen mensual y anual
│   │       └── profile/
│   ├── test/
│   └── pubspec.yaml
│
├── backend/                            # Proyecto NestJS (API)
│   ├── src/
│   │   ├── auth/                       # Registro, login, JWT
│   │   ├── users/                      # Gestión de usuarios
│   │   ├── products/                   # CRUD de productos del usuario
│   │   ├── categories/                 # Skincare, haircare, maquillaje...
│   │   ├── lists/                      # Tengo · Quiero · Favoritos · Usados
│   │   ├── routines/                   # Rutinas y pasos
│   │   ├── project-pan/                # Resumen de productos terminados
│   │   ├── barcode/                    # Integración con API externa de cosméticos
│   │   ├── notifications/              # Alertas de caducidad
│   │   ├── common/                     # Guards, interceptors, filtros
│   │   └── main.ts
│   └── package.json
│
├── docs/                               # Documentación extendida
│   ├── arquitectura.md
│   ├── api.md
│   ├── decisiones-tecnicas.md
│   └── guia-desarrollo.md
│
└── README.md
```

---

## 📡 API Reference

> Documentación completa en [`/docs/api.md`](./docs/api.md)

### Base URL
```
http://localhost:3000/api/v1
```

### Autenticación
```http
POST /auth/register
POST /auth/login
```

### Productos
```http
GET    /products              # Todos los productos del usuario
POST   /products              # Crear producto manualmente
GET    /products/:id          # Detalle de un producto
PATCH  /products/:id          # Actualizar producto
DELETE /products/:id          # Eliminar producto
GET    /products/expiring     # Productos próximos a caducar
```

### Escaneo de código de barras
```http
GET    /barcode/:code         # Buscar producto por código en API externa
```

### Listas
```http
GET    /lists/:type           # Obtener lista (have | want | favorites | used)
POST   /lists/:type/:productId  # Añadir producto a una lista
DELETE /lists/:type/:productId  # Quitar producto de una lista
```

### Rutinas
```http
GET    /routines              # Rutinas propias del usuario
POST   /routines              # Crear rutina
PATCH  /routines/:id          # Actualizar rutina
DELETE /routines/:id          # Eliminar rutina
GET    /routines/public       # Ver rutinas públicas de otros usuarios
```

### Project Pan
```http
GET    /project-pan/monthly   # Resumen mensual de productos usados
GET    /project-pan/yearly    # Resumen anual (Wrapped)
```

---

## 🔐 Variables de entorno

### Backend (`backend/.env`)

```env
# Base de datos
MONGODB_URI=mongodb://localhost:27017/[nombre-bd]

# Servidor
PORT=3000
NODE_ENV=development

# JWT (si usas autenticación con tokens)
JWT_SECRET=tu_secreto_aqui
JWT_EXPIRES_IN=7d

# [Otras variables que necesites]
```

> ⚠️ **Nunca subas el archivo `.env` a Git.** Asegúrate de que está en `.gitignore`.

---

## 📊 Estado del proyecto

| Módulo | Estado |
|--------|--------|
| Autenticación (registro y login) | 🔄 En desarrollo |
| Gestión de productos y categorías | 🔄 En desarrollo |
| Control de caducidades | ⏳ Pendiente |
| Escaneo de código de barras | ⏳ Pendiente |
| Listas (tengo / quiero / favoritos / usados) | ⏳ Pendiente |
| Project Pan (resumen mensual y anual) | ⏳ Pendiente |
| Módulo de rutinas | ⏳ Pendiente |
| Rutinas públicas | ⏳ Pendiente |
| Notificaciones de caducidad | ⏳ Pendiente |
| Publicación en Play Store | ⏳ Pendiente |

---

## 👤 Autor

**[Tu nombre]**

- 📧 Email: [tu-email@ejemplo.com]
- 🐙 GitHub: [@tu-usuario](https://github.com/tu-usuario)
- 🎓 Centro: [Nombre de tu universidad / escuela]
- 📚 TFG — [Año académico]

---

## 📄 Licencia

Este proyecto ha sido desarrollado como Trabajo de Fin de Grado y su uso está restringido a fines académicos. Ver [`LICENSE`](./LICENSE) para más información.
