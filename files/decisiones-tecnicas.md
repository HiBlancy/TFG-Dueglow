# 🧠 Decisiones Técnicas

Este documento justifica las principales elecciones tecnológicas y de diseño del proyecto. Es especialmente relevante en el contexto de un TFG, ya que demuestra capacidad de análisis y criterio técnico.

---

## 1. Flutter como framework de desarrollo móvil

**Decisión:** Usar Flutter en lugar de desarrollo nativo (Android/Kotlin o iOS/Swift) o React Native.

**Razones:**
- **Multiplataforma real:** Un único código base genera apps para Android e iOS. Dado que el objetivo es publicar en la Play Store (y potencialmente en el App Store en el futuro), Flutter reduce significativamente el tiempo de desarrollo.
- **Rendimiento:** Flutter compila a código nativo ARM, lo que ofrece un rendimiento superior a los frameworks basados en WebView (como Ionic).
- **UI consistente:** Flutter dibuja sus propios widgets, lo que garantiza una apariencia idéntica en todos los dispositivos sin depender de componentes nativos del SO.
- **Dart:** El lenguaje es tipado, moderno y fácil de aprender si ya se conoce Java o JavaScript.
- **Comunidad y ecosistema:** Flutter tiene una comunidad activa y una gran cantidad de packages en pub.dev.

**Alternativas consideradas:**

| Alternativa | Motivo de descarte |
|-------------|-------------------|
| Android nativo (Kotlin) | Solo cubriría Android; el proyecto aspira a ser multiplataforma |
| React Native | Mayor complejidad de configuración; rendimiento inferior en animaciones |
| Ionic / Capacitor | Basado en WebView; rendimiento notablemente inferior |

---

## 2. NestJS como framework de backend

**Decisión:** Usar NestJS en lugar de Express puro, FastAPI (Python) o Spring Boot (Java).

**Razones:**
- **Arquitectura modular:** NestJS impone una estructura clara de módulos, controladores y servicios, lo que facilita la escalabilidad y el mantenimiento del código.
- **TypeScript nativo:** El tipado estático reduce errores en tiempo de desarrollo y mejora la experiencia con el editor.
- **Decoradores y DI:** El sistema de inyección de dependencias de NestJS hace el código más testeable y desacoplado.
- **Integración perfecta con Mongoose:** El módulo `@nestjs/mongoose` facilita la definición de esquemas y la interacción con MongoDB.
- **Validación con class-validator:** La validación de DTOs es declarativa y muy cómoda de implementar.

**Alternativas consideradas:**

| Alternativa | Motivo de descarte |
|-------------|-------------------|
| Express puro | Sin estructura impuesta; requiere más configuración y disciplina para mantener el orden |
| FastAPI (Python) | Cambio de ecosistema; el equipo tiene mayor experiencia en JavaScript/TypeScript |
| Spring Boot | Excesivamente complejo para el alcance de este proyecto; verbosidad de Java |

---

## 3. MongoDB como base de datos

**Decisión:** Usar MongoDB (NoSQL documental) en lugar de PostgreSQL u otra base de datos relacional.

**Razones:**
- **Flexibilidad de esquema:** Durante el desarrollo, los modelos de datos evolucionan con frecuencia. MongoDB permite modificar la estructura de los documentos sin migraciones complejas.
- **Naturaleza de los datos:** Los datos del proyecto tienen una estructura jerárquica y variable que encaja bien con el modelo documental de MongoDB.
- **Integración con NestJS:** La combinación NestJS + Mongoose + MongoDB está muy bien documentada y tiene soporte oficial.
- **MongoDB Compass:** Permite visualizar y gestionar los datos de forma gráfica desde cualquier ordenador, lo cual es muy útil durante el desarrollo.
- **MongoDB Atlas:** Facilita el despliegue en la nube sin necesidad de gestionar servidores propios.

**Alternativas consideradas:**

| Alternativa | Motivo de descarte |
|-------------|-------------------|
| PostgreSQL | Las relaciones de los datos no son suficientemente complejas para justificar un modelo relacional estricto |
| Firebase Firestore | Menor control sobre la lógica del servidor; el backend propio aporta más valor académico al TFG |
| MySQL | Similar a PostgreSQL; esquema rígido innecesario para este proyecto |

---

## 4. MongoDB Compass para la visualización de datos

**Decisión:** Usar MongoDB Compass como herramienta de administración visual de la base de datos.

**Razones:**
- **Acceso desde cualquier equipo:** Conectándose a la misma URI (local o Atlas), se puede explorar la base de datos desde cualquier ordenador sin configuración adicional.
- **Sin coste:** Compass es gratuito y de código abierto.
- **Integración directa:** Al usar MongoDB como base de datos, Compass es la herramienta oficial de visualización, sin capas de abstracción adicionales.

---

## 5. Autenticación con JWT

**Decisión:** Usar JSON Web Tokens (JWT) para la autenticación, en lugar de sesiones en servidor o OAuth.

**Razones:**
- **Stateless:** El servidor no necesita almacenar sesiones; el token contiene toda la información necesaria.
- **Compatibilidad móvil:** Las apps móviles no gestionan cookies de forma nativa; los tokens son la solución estándar.
- **Sencillez:** Para el alcance de este proyecto, JWT ofrece un equilibrio perfecto entre seguridad y complejidad de implementación.
- **Ecosistema NestJS:** El módulo `@nestjs/jwt` + Passport hace que la implementación sea limpia y bien estructurada.

---

## 6. Estructura de carpetas en Flutter

**Decisión:** Organizar el proyecto Flutter por capas (data / domain / presentation) inspirándose en Clean Architecture.

**Razones:**
- **Separación de responsabilidades:** Cada capa tiene una responsabilidad clara y no depende de los detalles de implementación de las otras.
- **Testabilidad:** Con los repositorios abstractos, se pueden mockear las fuentes de datos en los tests.
- **Escalabilidad:** Añadir nuevas funcionalidades implica añadir nuevos módulos sin tocar los existentes.

> Nota: Se ha adoptado una versión simplificada de Clean Architecture, adaptada al alcance del TFG. No se han implementado todos los patrones del libro original para mantener la complejidad manejable.

---

## 7. Decisiones sobre la publicación en Play Store

**Decisión:** Desarrollar la app con intención de publicación en Google Play Store.

**Implicaciones técnicas:**
- El `applicationId` en `android/app/build.gradle` debe ser único y definitivo antes de publicar.
- Se debe generar un **keystore** para firmar el APK/AAB de release (y custodiarlo con cuidado).
- La app debe cumplir las políticas de Google Play (privacidad, permisos justificados, etc.).
- Se recomienda el formato **AAB (Android App Bundle)** en lugar de APK para la distribución en Play Store.
- Se necesitará una cuenta de desarrollador en Google Play Console (25$ de pago único).

---

## Registro de cambios en decisiones

| Fecha | Decisión | Cambio |
|-------|----------|--------|
| [dd/mm/aaaa] | [Tecnología] | [Descripción del cambio y motivo] |

> Este apartado es útil para documentar cuando se cambia de una tecnología o enfoque a otro durante el desarrollo.
