# Club Ramiro D'Agnone

Aplicación móvil para la **gestión de espacios deportivos**: permite consultar sedes y canchas, ver la disponibilidad horaria, reservar, cancelar y recibir notificaciones push sobre reservas próximas.

Trabajo Práctico de **Programación Avanzada II** — Universidad de Morón.

**Autor:** Ramiro D'Agnone

| Componente | Tecnología |
|---|---|
| Aplicación móvil | Flutter (Dart) |
| API REST | Python 3.13 + FastAPI (documentada con Swagger/OpenAPI) |
| Base de datos | PostgreSQL (SQLAlchemy + Alembic para migraciones) |
| Autenticación | Firebase Authentication |
| Notificaciones push | Firebase Cloud Messaging (FCM) |
| Nube | Render (API y base de datos) |
| Diseño UX/UI | Figma |

**API en producción:** https://clubramirodagnone.onrender.com
**Swagger (documentación interactiva):** https://clubramirodagnone.onrender.com/docs

> **Nota:** el plan gratuito de Render duerme el servicio tras un rato sin uso. La primera request puede tardar hasta ~1 minuto en responder; la app tiene un timeout de 60 s para contemplarlo.

---

## Funcionalidades

- Registro, inicio de sesión y recuperación de contraseña (Firebase Auth).
- Perfil de usuario: ver y editar nombre, apellido y fecha de nacimiento (el email no es editable), cambiar contraseña, modo claro/oscuro y cierre de sesión.
- Listado de sedes con dirección, horarios de funcionamiento y deportes que ofrecen.
- Listado de canchas por sede, con precio por hora.
- Consulta de horarios disponibles por cancha, fecha y duración (1 o 2 horas).
- Reserva de cancha, con validación de disponibilidad en el backend.
- Listado de reservas próximas e historial.
- Cancelación de reservas (el horario vuelve a quedar disponible).
- Manejo de errores: sin conexión, servidor caído, credenciales incorrectas, usuario ya registrado, horario ya ocupado, etc.
- Notificaciones push (Android).

### Reglas de negocio (validadas en el backend)

- Las reservas deben ser en horas completas (inicio y fin en el minuto 00) y durar **al menos 1 hora**.
- Deben estar dentro del horario de funcionamiento de la sede (el fin no puede superar el cierre).
- Deben ser para un horario futuro.
- No puede haber superposición de reservas activas sobre la misma cancha. Se valida en la API y además lo garantiza la base de datos con una *exclusion constraint* de PostgreSQL (`btree_gist`), que cubre el caso de dos requests simultáneas.
- Solo se pueden cancelar reservas activas cuyo horario todavía no comenzó.
- Las operaciones de usuarios y reservas identifican al usuario autenticado a partir del token de Firebase.
- Nombre de cada cancha con formato `Sede_Dirección_Deporte_Variante_Número` (ej.: `Moron_Rivadavia_19850_Futbol_F5_1`).

---

## Modelo de datos

| Tabla | Descripción | Campos principales |
|---|---|---|
| `users` | Perfil del usuario (vinculado a Firebase) | `id`, `firebase_uid`, `email`, `first_name`, `last_name`, `birth_date`, `role` (`user`/`admin`) |
| `venues` | Sedes | `id`, `name`, `address`, `opening_time`, `closing_time`, `is_active` |
| `sport_spaces` | Espacios deportivos (canchas) | `id`, `venue_id` → venues, `sport`, `variant`, `number`, `name` (único), `price_per_hour`, `is_active` |
| `bookings` | Reservas | `id`, `user_id` → users, `sport_space_id` → sport_spaces, `start_at`, `end_at`, `price`, `status` (`active`/`cancelled`), `cancelled_by`, `cancelled_at`, `cancel_reason`, `reminder_sent_at` |
| `device_tokens` | Tokens FCM de los dispositivos | `id`, `user_id` → users, `token` (único), `platform` |

Relaciones: una sede tiene muchos espacios deportivos; un espacio tiene muchas reservas; un usuario tiene muchas reservas y muchos dispositivos.

El estado `completed` de una reserva **no se guarda**: se calcula cuando una reserva activa ya terminó.

---

## Endpoints principales

Todos requieren el header `Authorization: Bearer <token de Firebase>`, salvo `/health` y `/health/db`. La lista completa y probable desde Swagger en `/docs`.

| Método | Ruta | Descripción |
|---|---|---|
| POST | `/users` | Crea el perfil tras el registro en Firebase |
| GET | `/users/me` | Perfil del usuario autenticado |
| PUT | `/users/me` | Edita nombre, apellido y fecha de nacimiento |
| POST | `/users/me/device-token` | Registra el token FCM del dispositivo |
| GET | `/venues` | Lista de sedes |
| GET | `/venues/{venue_id}/spaces` | Canchas de una sede |
| GET | `/sport-spaces/{space_id}/availability?date=YYYY-MM-DD&duration=1` | Franjas horarias del día y su disponibilidad |
| POST | `/bookings` | Crea una reserva |
| GET | `/bookings/me?scope=upcoming\|history` | Reservas del usuario |
| PATCH | `/bookings/{booking_id}/cancel` | Cancela una reserva |
| GET | `/health`, `/health/db` | Estado del servicio y de la base de datos |

Endpoints de prueba (para desarrollo): `POST /users/me/test-notification` y `POST /users/me/test-reminders`.

---

## Requisitos previos

- [Git](https://git-scm.com/)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (con Android Studio y Android SDK Command-line Tools para correr en emulador)
- [Python 3.13](https://www.python.org/downloads/)
- [PostgreSQL](https://www.postgresql.org/download/) (solo si se quiere correr el backend en local)
- Un proyecto de [Firebase](https://console.firebase.google.com/) con Authentication de Correo electrónico/contraseña habilitado
- (Opcional) [Node.js](https://nodejs.org/) y Firebase CLI + FlutterFire CLI, solo si se quiere reconfigurar Firebase

Clonar el repositorio:

```bash
git clone https://github.com/<usuario>/ClubRamiroDAgnone.git
cd ClubRamiroDAgnone
```

---

## Backend (API REST)

Todos los comandos se ejecutan dentro de la carpeta `backend/`. Los ejemplos usan PowerShell (Windows).

### 1. Entorno virtual y dependencias

```powershell
cd backend
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt

```sql
CREATE DATABASE gestion_espacios;
```

### 2. Variables de entorno

Copiar el archivo de ejemplo y completarlo:

```powershell
copy .env.example .env
```

```env
DATABASE_URL=postgresql+psycopg://postgres:TU_PASSWORD@localhost:5432/gestion_espacios
FIREBASE_CREDENTIALS_PATH=firebase-service-account.json
```

### 3. Credenciales de Firebase Admin

En la consola de Firebase: **Configuración del proyecto → Cuentas de servicio → Generar nueva clave privada**. Guardar el JSON descargado como `backend/firebase-service-account.json`.

> `.env` y `firebase-service-account.json` están en el `.gitignore`. **Nunca subirlos al repositorio.**

### 4. Migraciones y datos de ejemplo

```powershell
alembic upgrade head
python -m app.seed
```

`alembic upgrade head` crea todas las tablas (incluida la restricción anti-superposición, que requiere la extensión `btree_gist` de PostgreSQL). `app.seed` carga 4 sedes (Morón, Ramos Mejía, San Justo y Castelar) con sus canchas; se puede ejecutar más de una vez sin duplicar datos.

### 5. Levantar el servidor

```powershell
uvicorn app.main:app --reload
```

- API: http://127.0.0.1:8000
- Swagger: http://127.0.0.1:8000/docs
- Chequeo: http://127.0.0.1:8000/health y http://127.0.0.1:8000/health/db

### Probar endpoints protegidos desde Swagger

Los endpoints exigen un token de Firebase. Para probarlos en `/docs`, obtener un ID token (por ejemplo, iniciando sesión en la app: en modo debug se imprime en la consola como `ID token: ...`), presionar **Authorize** y pegarlo.

### Despliegue en Render

1. **Base de datos:** crear una instancia de PostgreSQL en Render y copiar su *External Database URL*. Para SQLAlchemy con psycopg, debe empezar con `postgresql+psycopg://`.
2. **Web Service:** crear un servicio nuevo conectado al repositorio de GitHub con:
   - **Root Directory:** `backend`
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
3. **Variables de entorno:** `DATABASE_URL` (la de Render) y `FIREBASE_CREDENTIALS_PATH`.
4. **Credenciales de Firebase:** cargar el JSON como *Secret File* en Render y apuntar `FIREBASE_CREDENTIALS_PATH` a su ruta (por ejemplo `/etc/secrets/firebase-service-account.json`).
5. **Migraciones y seed en la base de Render:** desde la máquina local, con `DATABASE_URL` apuntando a la base de Render:

   ```powershell
   $env:DATABASE_URL = "postgresql+psycopg://...render..."
   alembic upgrade head
   python -m app.seed
   ```

6. Verificar en `https://<tu-servicio>.onrender.com/health/db` y `/docs`.

---

## Aplicación móvil (Flutter)

### 1. Dependencias

Desde la raíz del repositorio:

```bash
flutter pub get
flutter doctor
```

### 2. Firebase

El repositorio ya incluye la configuración del proyecto de Firebase (`lib/firebase_options.dart` y `android/app/google-services.json`), por lo que **no hace falta configurar nada más** para correr la app.

Si se quisiera usar otro proyecto de Firebase:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### 3. URL de la API

La app apunta por defecto a la API de producción en Render. La constante está en `lib/services/api_client.dart`:

```dart
const apiBaseUrl = "https://clubramirodagnone.onrender.com";
```

Para usar el backend local, cambiar esa constante por:

- `http://10.0.2.2:8000` si se corre en el **emulador Android** (el emulador accede a la PC por `10.0.2.2`).
- `http://127.0.0.1:8000` si se corre en **Chrome**.

> El CORS del backend solo permite orígenes `localhost` / `127.0.0.1`, que es lo que usa Flutter web en desarrollo.

### 4. Ejecutar la app

En el emulador Android (crear uno desde Android Studio → Device Manager; para las notificaciones usar una imagen **con Google Play**):

```bash
flutter devices
flutter run
```

En Chrome:

```bash
flutter run -d chrome
```

### 5. Notificaciones push

- Funcionan en **Android**; en web están deshabilitadas.
- Al iniciar sesión, la app pide permiso de notificaciones y registra el token FCM del dispositivo en el backend (`POST /users/me/device-token`).
- Para probarlas: con la app en segundo plano, llamar a `POST /users/me/test-notification` desde Swagger. La respuesta `{"delivered": 1}` indica que se envió a un dispositivo.
- Los recordatorios de reservas (`send_hourly_reminders` en `backend/app/reminders.py`) avisan, al comenzar cada hora, de las reservas activas que empiezan en la hora siguiente. Se pueden disparar manualmente con `POST /users/me/test-reminders`.

### Generar un APK

```bash
flutter build apk --release
```

El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`.

## Estado del proyecto

Implementado: registro, login y recuperación de contraseña, perfil, sedes, canchas, disponibilidad, reservas (crear, listar, cancelar, historial), manejo de errores, backend y base de datos desplegados en Render, registro de dispositivos y notificaciónes.