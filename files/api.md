# 📡 API Reference — DueGlow

Documentación completa de los endpoints de la API REST del backend NestJS de DueGlow.

## Información general

| Parámetro | Valor |
|-----------|-------|
| **Base URL (desarrollo)** | `http://localhost:3000/api/v1` |
| **Base URL (producción)** | `https://[tu-dominio]/api/v1` |
| **Formato** | JSON |
| **Autenticación** | Bearer Token (JWT) |
| **Versión** | v1 |

---

## Autenticación

La mayoría de los endpoints requieren autenticación. Incluye el token JWT en la cabecera:

```http
Authorization: Bearer <tu_token_jwt>
```

---

## Módulos

- [Auth](#-auth)
- [Users](#-users)
- [Products](#-products)
- [Barcode — API externa](#-barcode--api-externa)
- [Categories](#-categories)
- [Lists](#-lists)
- [Routines](#-routines)
- [Project Pan](#-project-pan)
- [Notifications](#-notifications)

---

## 🔐 Auth

#### Registrar usuario
```http
POST /auth/register
```

**Body:**
```json
{
  "email": "usuario@ejemplo.com",
  "password": "contraseña123",
  "nombre": "Ana García"
}
```

**Respuesta `201 Created`:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "_id": "6507a1b2c3d4e5f6a7b8c9d0",
    "email": "usuario@ejemplo.com",
    "nombre": "Ana García"
  }
}
```

---

#### Iniciar sesión
```http
POST /auth/login
```

**Body:**
```json
{
  "email": "usuario@ejemplo.com",
  "password": "contraseña123"
}
```

**Respuesta `200 OK`:** mismo formato que el registro.

---

## 👤 Users

#### Obtener perfil propio
```http
GET /users/me
```
🔒 *Requiere autenticación*

**Respuesta `200 OK`:**
```json
{
  "_id": "6507a1b2c3d4e5f6a7b8c9d0",
  "email": "usuario@ejemplo.com",
  "nombre": "Ana García",
  "createdAt": "2024-01-15T10:30:00.000Z"
}
```

---

#### Actualizar perfil
```http
PATCH /users/me
```
🔒 *Requiere autenticación*

**Body (campos opcionales):**
```json
{
  "nombre": "Ana García López"
}
```

---

## 📦 Products

#### Obtener todos los productos del usuario
```http
GET /products
```
🔒 *Requiere autenticación*

**Query params opcionales:**
```
?category=skincare&list=have&expiringSoon=true&page=1&limit=20
```

**Respuesta `200 OK`:**
```json
{
  "data": [
    {
      "_id": "...",
      "name": "Vitamin C Serum",
      "brand": "The Ordinary",
      "category": "skincare",
      "subcategory": "serum",
      "barcode": "3600523541874",
      "expirationDate": "2025-06-01T00:00:00.000Z",
      "openedDate": "2024-12-01T00:00:00.000Z",
      "pao": 12,
      "imageUrl": "https://...",
      "notes": "Usar por la mañana",
      "lists": ["have", "favorites"],
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  ],
  "total": 45,
  "page": 1,
  "limit": 20
}
```

> `pao` = Period After Opening en meses (el símbolo del tarro abierto que aparece en los cosméticos)

---

#### Obtener productos próximos a caducar
```http
GET /products/expiring
```
🔒 *Requiere autenticación*

**Query params:**
```
?days=30    # Productos que caducan en los próximos N días (default: 30)
```

---

#### Obtener un producto por ID
```http
GET /products/:id
```
🔒 *Requiere autenticación*

---

#### Crear producto manualmente
```http
POST /products
```
🔒 *Requiere autenticación*

**Body:**
```json
{
  "name": "Hidratante facial",
  "brand": "CeraVe",
  "category": "skincare",
  "subcategory": "moisturizer",
  "barcode": "3600523541874",
  "expirationDate": "2025-12-01",
  "openedDate": "2024-06-01",
  "pao": 12,
  "imageUrl": "https://...",
  "notes": "Aplicar por las noches"
}
```

---

#### Actualizar producto
```http
PATCH /products/:id
```
🔒 *Requiere autenticación*

**Body:** cualquier campo del producto (todos opcionales).

---

#### Eliminar producto
```http
DELETE /products/:id
```
🔒 *Requiere autenticación*

---

## 📷 Barcode — API externa

#### Buscar producto por código de barras
```http
GET /barcode/:code
```
🔒 *Requiere autenticación*

Consulta la API externa de cosméticos (Open Beauty Facts u otra) y devuelve los datos del producto si existe.

**Respuesta `200 OK` (producto encontrado):**
```json
{
  "found": true,
  "product": {
    "name": "Vitamin C Serum",
    "brand": "The Ordinary",
    "category": "skincare",
    "imageUrl": "https://...",
    "barcode": "3600523541874",
    "source": "open_beauty_facts"
  }
}
```

**Respuesta `200 OK` (no encontrado):**
```json
{
  "found": false,
  "message": "Producto no encontrado. Puedes añadirlo manualmente."
}
```

---

## 🗂 Categories

#### Obtener todas las categorías y subcategorías
```http
GET /categories
```
🔒 *Requiere autenticación*

**Respuesta `200 OK`:**
```json
[
  {
    "id": "skincare",
    "label": "Cuidado facial",
    "subcategories": ["cleanser", "toner", "serum", "moisturizer", "spf", "eye-cream", "mask"]
  },
  {
    "id": "haircare",
    "label": "Cuidado capilar",
    "subcategories": ["shampoo", "conditioner", "mask", "heat-protector", "oil", "serum"]
  },
  {
    "id": "bodycare",
    "label": "Cuidado corporal",
    "subcategories": ["lotion", "cream", "oil", "scrub", "deodorant"]
  },
  {
    "id": "makeup",
    "label": "Maquillaje",
    "subcategories": ["base", "concealer", "blush", "bronzer", "highlighter", "eyeshadow", "eyeliner", "mascara", "lipstick", "lipgloss", "setting-spray", "primer"]
  },
  {
    "id": "fragrance",
    "label": "Perfumería",
    "subcategories": ["perfume", "body-mist", "eau-de-toilette"]
  }
]
```

---

## 📋 Lists

DueGlow maneja 4 tipos de lista: `have` (tengo) · `want` (quiero) · `favorites` (favoritos) · `used` (ya usados).

Un mismo producto puede estar en varias listas a la vez (por ejemplo, en `have` y `favorites`).

#### Obtener productos de una lista
```http
GET /lists/:type
```
🔒 *Requiere autenticación*

`:type` puede ser: `have` | `want` | `favorites` | `used`

---

#### Añadir producto a una lista
```http
POST /lists/:type/:productId
```
🔒 *Requiere autenticación*

---

#### Quitar producto de una lista
```http
DELETE /lists/:type/:productId
```
🔒 *Requiere autenticación*

---

#### Marcar producto como usado (añadir a `used`)
```http
POST /lists/used/:productId
```
🔒 *Requiere autenticación*

**Body:**
```json
{
  "finishedDate": "2024-06-15",
  "rating": 4,
  "wouldRepurchase": true,
  "review": "Me ha encantado, la piel muy hidratada"
}
```

---

## 🧴 Routines

#### Obtener rutinas propias
```http
GET /routines
```
🔒 *Requiere autenticación*

**Respuesta `200 OK`:**
```json
[
  {
    "_id": "...",
    "name": "Rutina de noche",
    "category": "skincare",
    "isPublic": false,
    "steps": [
      { "order": 1, "productId": "...", "productName": "Limpiador", "comment": "Con agua tibia" },
      { "order": 2, "productId": "...", "productName": "Tónico", "comment": "Con algodón" },
      { "order": 3, "productId": "...", "productName": "Serum vitamina C", "comment": "2-3 gotas" }
    ],
    "createdAt": "2024-01-15T10:30:00.000Z"
  }
]
```

---

#### Ver rutinas públicas de otros usuarios
```http
GET /routines/public
```
🔒 *Requiere autenticación*

**Query params:**
```
?category=skincare&page=1&limit=10
```

---

#### Crear rutina
```http
POST /routines
```
🔒 *Requiere autenticación*

**Body:**
```json
{
  "name": "Rutina de mañana",
  "category": "skincare",
  "isPublic": false,
  "steps": [
    { "order": 1, "productId": "...", "comment": "Con agua fría" },
    { "order": 2, "productId": "...", "comment": "Dejar absorber 5 min" }
  ]
}
```

---

#### Actualizar rutina
```http
PATCH /routines/:id
```
🔒 *Requiere autenticación* — solo el propietario puede editar.

---

#### Eliminar rutina
```http
DELETE /routines/:id
```
🔒 *Requiere autenticación* — solo el propietario puede eliminar.

---

## ✨ Project Pan

El Project Pan registra los productos terminados y genera resúmenes visuales periódicos al estilo Spotify Wrapped.

#### Resumen mensual
```http
GET /project-pan/monthly
```
🔒 *Requiere autenticación*

**Query params:**
```
?month=6&year=2024
```

**Respuesta `200 OK`:**
```json
{
  "period": "June 2024",
  "totalProductsUsed": 5,
  "byCategory": {
    "skincare": 3,
    "haircare": 1,
    "makeup": 1
  },
  "products": [
    {
      "name": "Niacinamide 10%",
      "brand": "The Ordinary",
      "category": "skincare",
      "finishedDate": "2024-06-10",
      "rating": 5,
      "wouldRepurchase": true
    }
  ],
  "topCategory": "skincare",
  "repurchaseRate": 80
}
```

---

#### Resumen anual (Wrapped)
```http
GET /project-pan/yearly
```
🔒 *Requiere autenticación*

**Query params:**
```
?year=2024
```

**Respuesta `200 OK`:**
```json
{
  "year": 2024,
  "totalProductsUsed": 47,
  "byCategory": {
    "skincare": 18,
    "makeup": 15,
    "haircare": 8,
    "bodycare": 6
  },
  "topBrand": "The Ordinary",
  "mostUsedCategory": "skincare",
  "repurchaseRate": 72,
  "monthlyBreakdown": [
    { "month": 1, "total": 3 },
    { "month": 2, "total": 4 }
  ]
}
```

---

## 🔔 Notifications

#### Obtener alertas de caducidad activas
```http
GET /notifications/expiring
```
🔒 *Requiere autenticación*

**Respuesta `200 OK`:**
```json
[
  {
    "productId": "...",
    "productName": "Sunscreen SPF50",
    "brand": "ISDIN",
    "expirationDate": "2024-07-15",
    "daysRemaining": 12,
    "urgency": "high"
  }
]
```

> `urgency`: `low` (más de 60 días) · `medium` (30–60 días) · `high` (menos de 30 días) · `expired` (ya caducado)

---

## Códigos de respuesta HTTP

| Código | Significado |
|--------|-------------|
| `200` | OK — Petición exitosa |
| `201` | Created — Recurso creado |
| `400` | Bad Request — Datos de entrada incorrectos |
| `401` | Unauthorized — Token inválido o ausente |
| `403` | Forbidden — Sin permisos sobre este recurso |
| `404` | Not Found — Recurso no encontrado |
| `500` | Internal Server Error — Error en el servidor |

## Estructura de error estándar

```json
{
  "statusCode": 404,
  "message": "Producto no encontrado",
  "error": "Not Found"
}
```
