# 🏗 Arquitectura del Proyecto

## Índice

- [Visión general](#visión-general)
- [Arquitectura del sistema](#arquitectura-del-sistema)
- [Frontend — Flutter](#frontend--flutter)
- [Backend — NestJS](#backend--nestjs)
- [Base de datos — MongoDB](#base-de-datos--mongodb)
- [Flujo de datos](#flujo-de-datos)
- [Comunicación cliente-servidor](#comunicación-cliente-servidor)
- [Seguridad](#seguridad)

---

## Visión general

El sistema sigue una arquitectura **cliente-servidor desacoplada en tres capas**:

- **Capa de presentación:** Aplicación Flutter que consume la API REST.
- **Capa de negocio:** API construida con NestJS, organizada en módulos por dominio.
- **Capa de datos:** Base de datos MongoDB, accesible también mediante MongoDB Compass.

Este diseño garantiza que el frontend y el backend puedan evolucionar de forma independiente, y permite en el futuro añadir otros clientes (web, escritorio) sin modificar el backend.

---

## Arquitectura del sistema

```
┌──────────────────────────────────────────────────────────────────┐
│                        DISPOSITIVO MÓVIL                          │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    App Flutter                           │    │
│  │                                                         │    │
│  │  Presentation Layer                                     │    │
│  │  ├── Screens (páginas de la app)                        │    │
│  │  ├── Widgets (componentes reutilizables)                │    │
│  │  └── State Management ([Provider/Riverpod/Bloc])        │    │
│  │                  │                                      │    │
│  │  Data Layer                                             │    │
│  │  ├── Repositories (abstracción del origen de datos)     │    │
│  │  ├── Remote DataSource (llamadas HTTP)                  │    │
│  │  └── Models (serialización JSON)                        │    │
│  └─────────────────────────────┬───────────────────────────┘    │
└────────────────────────────────┼─────────────────────────────────┘
                                 │
                     HTTPS / REST API (JSON)
                                 │
┌────────────────────────────────┼─────────────────────────────────┐
│                         SERVIDOR                                  │
│  ┌─────────────────────────────▼───────────────────────────┐    │
│  │                    API NestJS                            │    │
│  │                                                         │    │
│  │  ├── Controllers  → Reciben y validan requests HTTP     │    │
│  │  ├── Services     → Lógica de negocio                   │    │
│  │  ├── Schemas      → Modelos Mongoose / MongoDB          │    │
│  │  ├── DTOs         → Validación de entrada (class-validator) │  │
│  │  ├── Guards       → Protección de rutas (JWT)           │    │
│  │  └── Interceptors → Transformación de respuestas        │    │
│  └─────────────────────────────┬───────────────────────────┘    │
└────────────────────────────────┼─────────────────────────────────┘
                                 │
                          Mongoose ODM
                                 │
┌────────────────────────────────┼─────────────────────────────────┐
│                      BASE DE DATOS                                │
│  ┌─────────────────────────────▼───────────────────────────┐    │
│  │                      MongoDB                             │    │
│  │                                                         │    │
│  │  Collections: users | [colección2] | [colección3]       │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              ▲                                    │
│                    MongoDB Compass (GUI)                          │
│              Acceso visual desde cualquier equipo                 │
└──────────────────────────────────────────────────────────────────┘
```

---

## Frontend — Flutter

### Patrón de arquitectura

La app Flutter sigue el patrón **[Clean Architecture / MVVM / MVC]** — *actualiza según lo que uses*.

```
lib/
├── core/
│   ├── constants/          # URLs, colores, strings constantes
│   ├── errors/             # Clases de error personalizadas
│   ├── network/            # Cliente HTTP (Dio / http)
│   └── theme/              # Tema global de la app
│
├── data/
│   ├── models/             # Clases con fromJson / toJson
│   ├── repositories/       # Implementación de repositorios
│   └── datasources/
│       └── remote/         # Llamadas a la API REST
│
├── domain/                 # (Si usas Clean Architecture)
│   ├── entities/           # Entidades de negocio puras
│   ├── repositories/       # Interfaces abstractas
│   └── usecases/           # Casos de uso
│
└── presentation/
    ├── screens/            # Pantallas completas
    ├── widgets/            # Componentes reutilizables
    └── [state]/            # Providers / Cubits / ViewModels
```

### Gestión de estado

Se utiliza **[Provider / Riverpod / Bloc]** para la gestión del estado global. La elección se justifica en [`decisiones-tecnicas.md`](./decisiones-tecnicas.md).

### Cliente HTTP

Las llamadas a la API se realizan con **[Dio / http package]**. Todas las peticiones incluyen el token JWT en la cabecera `Authorization: Bearer <token>`.

---

## Backend — NestJS

### Estructura modular

NestJS organiza el código por módulos, donde cada módulo encapsula su propio controlador, servicio y esquema:

```
src/
├── auth/                   # Autenticación (registro, login, JWT)
│   ├── dto/
│   ├── auth.controller.ts
│   ├── auth.service.ts
│   └── auth.module.ts
│
├── [modulo-1]/             # Reemplaza con tus módulos reales
│   ├── dto/                # CreateXxxDto, UpdateXxxDto
│   ├── schemas/            # Esquema Mongoose
│   ├── [modulo].controller.ts
│   ├── [modulo].service.ts
│   └── [modulo].module.ts
│
├── common/
│   ├── guards/             # JwtAuthGuard, RolesGuard
│   ├── interceptors/       # TransformInterceptor
│   ├── decorators/         # @CurrentUser(), @Roles()
│   └── filters/            # GlobalExceptionFilter
│
├── app.module.ts           # Módulo raíz
└── main.ts                 # Bootstrap y configuración global
```

### Pipeline de una request

```
Request entrante
      │
      ▼
  Middleware          → Logging, CORS, Helmet
      │
      ▼
  Guards              → ¿Está autenticado? ¿Tiene permisos?
      │
      ▼
  Interceptors (pre)  → Transformación de entrada
      │
      ▼
  Pipes               → Validación y transformación de DTOs
      │
      ▼
  Controller          → Enruta al método correcto
      │
      ▼
  Service             → Lógica de negocio
      │
      ▼
  Repository          → Operación en MongoDB (via Mongoose)
      │
      ▼
  Interceptors (post) → Transformación de respuesta
      │
      ▼
  Response al cliente
```

---

## Base de datos — MongoDB

### Colecciones principales

| Colección | Descripción |
|-----------|-------------|
| `users` | Usuarios registrados |
| `[colección2]` | [Descripción] |
| `[colección3]` | [Descripción] |

### Esquema de ejemplo — Users

```javascript
{
  _id: ObjectId,
  email: String (único, requerido),
  password: String (hasheado con bcrypt),
  nombre: String,
  createdAt: Date,
  updatedAt: Date
}
```

### Acceso con MongoDB Compass

MongoDB Compass permite explorar y editar los datos visualmente desde cualquier ordenador. Simplemente conecta con la misma URI de conexión definida en las variables de entorno.

> Si usas **MongoDB Atlas** (cloud), la URI está disponible en el panel de tu cluster y todos los desarrolladores pueden conectarse desde cualquier red.

---

## Flujo de datos

### Ejemplo: Login de usuario

```
1. Usuario introduce email y contraseña en Flutter
2. Flutter llama a AuthRepository.login(email, password)
3. AuthRepository llama a AuthRemoteDataSource.login()
4. Se realiza POST /api/v1/auth/login con el body JSON
5. NestJS AuthController recibe la petición
6. AuthService verifica las credenciales contra MongoDB
7. Si son correctas, genera y devuelve un JWT
8. Flutter almacena el token de forma segura (flutter_secure_storage)
9. Todas las peticiones siguientes incluyen el token en la cabecera
```

---

## Comunicación cliente-servidor

- **Protocolo:** HTTPS (HTTP en desarrollo local)
- **Formato:** JSON
- **Autenticación:** JWT (JSON Web Token) en cabecera `Authorization: Bearer`
- **Versionado de API:** `/api/v1/` — permite añadir versiones futuras sin romper clientes
- **Manejo de errores:** Respuestas estándar con código HTTP + mensaje descriptivo

```json
// Respuesta de error estándar
{
  "statusCode": 400,
  "message": "El email ya está registrado",
  "error": "Bad Request"
}
```

---

## Seguridad

- Las contraseñas se almacenan **hasheadas con bcrypt** (nunca en texto plano)
- Los tokens JWT tienen una **expiración configurada** (por defecto 7 días)
- Las rutas protegidas utilizan el **JwtAuthGuard** de NestJS
- Las variables sensibles se gestionan mediante **variables de entorno** (`.env`)
- El archivo `.env` está incluido en `.gitignore` y **nunca se sube al repositorio**
- En producción se recomienda configurar **CORS** para aceptar solo el origen de la app
