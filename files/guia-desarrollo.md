# 🛠 Guía de Desarrollo

Este documento describe las convenciones, flujos de trabajo y buenas prácticas para el desarrollo del proyecto. Es especialmente útil para retomar el trabajo después de un tiempo de inactividad, o para que cualquier otra persona pueda contribuir.

---

## Índice

- [Entorno de desarrollo](#entorno-de-desarrollo)
- [Flujo de trabajo con Git](#flujo-de-trabajo-con-git)
- [Convenciones de código](#convenciones-de-código)
- [Convenciones de la API](#convenciones-de-la-api)
- [Gestión de la base de datos](#gestión-de-la-base-de-datos)
- [Testing](#testing)
- [Checklist antes de un commit](#checklist-antes-de-un-commit)
- [Checklist para publicar en Play Store](#checklist-para-publicar-en-play-store)
- [Problemas conocidos y soluciones](#problemas-conocidos-y-soluciones)

---

## Entorno de desarrollo

### Versiones recomendadas

| Herramienta | Versión mínima | Comando de verificación |
|-------------|---------------|------------------------|
| Flutter | 3.x | `flutter --version` |
| Dart | 3.x | `dart --version` |
| Node.js | 18.x | `node --version` |
| npm | 9.x | `npm --version` |
| MongoDB | 7.x | `mongod --version` |

### IDEs recomendados

- **VS Code** con extensiones: Flutter, Dart, NestJS Files, MongoDB for VS Code
- **Android Studio** para la parte mobile (emulador integrado)

### Comandos de arranque rápido

```bash
# Terminal 1 — Backend
cd backend && npm run start:dev

# Terminal 2 — App Flutter (con emulador abierto)
cd app && flutter run

# Terminal 3 (opcional) — MongoDB local
mongod --dbpath /ruta/a/tus/datos
```

---

## Flujo de trabajo con Git

### Estructura de ramas

```
main          → Código estable, funcionando
  └── develop → Integración de nuevas funcionalidades
        ├── feature/nombre-funcionalidad
        ├── fix/descripcion-del-bug
        └── docs/que-documentas
```

### Convención de commits

Se sigue el estándar **Conventional Commits**:

```
<tipo>(<alcance>): <descripción corta>

Tipos:
  feat     → Nueva funcionalidad
  fix      → Corrección de un bug
  docs     → Cambios en documentación
  style    → Formato, sin cambios en lógica
  refactor → Refactorización de código
  test     → Añadir o modificar tests
  chore    → Tareas de mantenimiento (dependencias, config)
```

**Ejemplos:**
```
feat(auth): añadir endpoint de registro de usuario
fix(flutter): corregir error de navegación en pantalla de login
docs(api): añadir documentación del módulo de usuarios
refactor(backend): extraer lógica de validación a un pipe común
```

---

## Convenciones de código

### Flutter / Dart

- **Nombrado de archivos:** `snake_case.dart` (ej: `user_repository.dart`)
- **Nombrado de clases:** `PascalCase` (ej: `UserRepository`)
- **Nombrado de variables y métodos:** `camelCase` (ej: `getCurrentUser()`)
- **Widgets:** cada widget en su propio archivo si supera ~50 líneas
- **Imports:** ordenar en este orden: Dart SDK → paquetes externos → archivos locales
- Usar `const` siempre que sea posible para optimizar el rendimiento

```dart
// ✅ Correcto
class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.user});
  
  final User user;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Text(user.nombre),
    );
  }
}
```

### NestJS / TypeScript

- **Nombrado de archivos:** `kebab-case` (ej: `user.service.ts`, `create-user.dto.ts`)
- **Nombrado de clases:** `PascalCase` (ej: `UserService`)
- **Nombrado de métodos:** `camelCase` (ej: `findById()`)
- Siempre tipar los parámetros y el retorno de las funciones
- Usar `async/await` en lugar de `.then()/.catch()`
- Nunca exponer el campo `password` en las respuestas de la API

```typescript
// ✅ Correcto
async findById(id: string): Promise<User> {
  const user = await this.userModel.findById(id).select('-password');
  if (!user) {
    throw new NotFoundException(`Usuario con id ${id} no encontrado`);
  }
  return user;
}
```

### MongoDB / Esquemas Mongoose

- Los nombres de colecciones en **plural y minúsculas** (ej: `users`, `products`)
- Siempre incluir `timestamps: true` en los esquemas para tener `createdAt` y `updatedAt`
- Añadir índices (`@index`) en los campos por los que se filtra frecuentemente

```typescript
// ✅ Correcto
@Schema({ timestamps: true })
export class User {
  @Prop({ required: true, unique: true, lowercase: true })
  email: string;
  
  @Prop({ required: true })
  password: string;
}
```

---

## Convenciones de la API

- **Rutas en plural y kebab-case:** `/users`, `/user-profiles`
- **Acciones por método HTTP:** GET (leer), POST (crear), PATCH (actualizar parcial), DELETE (eliminar)
- **Respuestas siempre en JSON**
- **Nunca devolver el campo `password`** en ninguna respuesta
- **Paginación** en los listados: `{ data: [], total: N, page: N, limit: N }`
- **Mensajes de error descriptivos** pero sin revelar detalles internos del sistema

---

## Gestión de la base de datos

### Conexión local

```bash
# Iniciar MongoDB localmente
mongod

# Conectar con Compass
URI: mongodb://localhost:27017/[nombre-bd]
```

### Conexión con Atlas (cloud)

La URI de conexión se obtiene desde el panel de MongoDB Atlas:
```
mongodb+srv://usuario:password@cluster.mongodb.net/nombre-bd
```

> ⚠️ **NUNCA** comitear esta URI con credenciales reales. Siempre usar variables de entorno.

### Backups

Para hacer un backup de la base de datos local:
```bash
mongodump --db [nombre-bd] --out ./backups/$(date +%Y%m%d)
```

---

## Testing

### Backend (NestJS)

```bash
# Tests unitarios
npm run test

# Tests e2e
npm run test:e2e

# Coverage
npm run test:cov
```

### Flutter

```bash
# Tests unitarios y de widget
flutter test

# Test de integración (requiere emulador/dispositivo)
flutter test integration_test/
```

### Qué testear mínimamente para el TFG

- ✅ Services del backend (lógica de negocio)
- ✅ Al menos un repositorio de Flutter (mock del datasource)
- ✅ Los DTOs de validación del backend

---

## Checklist antes de un commit

- [ ] El código compila sin errores (`flutter build apk` / `npm run build`)
- [ ] No hay `console.log` / `print` de debug en el código
- [ ] No hay credenciales ni tokens hardcodeados
- [ ] El `.env` no está incluido en los archivos a commitear
- [ ] Los nuevos endpoints están documentados en `docs/api.md`
- [ ] Los cambios importantes de diseño están reflejados en `docs/arquitectura.md`

---

## Checklist para publicar en Play Store

### Preparación técnica

- [ ] `applicationId` definitivo en `android/app/build.gradle`
- [ ] `versionCode` y `versionName` actualizados
- [ ] Keystore generado y guardado en lugar seguro (¡no en el repositorio!)
- [ ] App firmada en modo release
- [ ] Icono de la app en todas las resoluciones (`flutter_launcher_icons`)
- [ ] Splash screen configurado (`flutter_native_splash`)
- [ ] Permisos en `AndroidManifest.xml` justificados y mínimos necesarios
- [ ] URL del backend apuntando a producción (no a `localhost`)
- [ ] App probada en un dispositivo físico en modo release

### Publicación

- [ ] Cuenta de desarrollador en Google Play Console (25$ único)
- [ ] Screenshots de la app (mínimo 2, máximo 8 por tipo de dispositivo)
- [ ] Descripción corta y completa en español
- [ ] Política de privacidad publicada (obligatoria si la app recopila datos)
- [ ] Clasificación de contenido completada
- [ ] AAB (Android App Bundle) generado: `flutter build appbundle --release`

---

## Problemas conocidos y soluciones

> Esta sección se actualiza conforme se encuentran y resuelven problemas durante el desarrollo.

### [Problema 1]

**Síntoma:** [Descripción de lo que ocurre]

**Causa:** [Por qué ocurre]

**Solución:**
```bash
# Comandos o pasos para resolverlo
```

---

### Flutter: Error de conexión al backend en emulador Android

**Síntoma:** La app no puede conectar con `http://localhost:3000`

**Causa:** En el emulador de Android, `localhost` apunta al propio emulador, no al ordenador host.

**Solución:** Usar la IP `10.0.2.2` en lugar de `localhost` cuando se desarrolla con el emulador de Android:
```dart
// En development
const baseUrl = 'http://10.0.2.2:3000/api/v1';
```

---

### NestJS: El token JWT expira y la app no lo gestiona

**Síntoma:** Después de X días, las peticiones devuelven 401 y la app no redirige al login.

**Solución:** Implementar un interceptor en Dio (Flutter) que detecte el error 401 y limpie el token almacenado, redirigiendo al usuario a la pantalla de login.
