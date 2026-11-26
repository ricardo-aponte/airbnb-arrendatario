# Airbnb Arrendatario — Aplicación Móvil para Anfitriones

Aplicación móvil nativa para **Arrendatarios (Anfitriones)** del ecosistema de reservas de alojamientos (estilo Airbnb), desarrollada en **Flutter** y **Dart**, conectada a la API REST compartida con la aplicación de clientes.

---

## Funcionalidades Principales

* **Autenticación de Arrendatarios:** Inicio de sesión y registro de anfitriones con persistencia de sesión local mediante `shared_preferences`.
* **Gestión de Alojamientos:** Listado de los lugares publicados por el anfitrión, junto con la creación y edición completa de propiedades (nombre, descripción, ciudad, capacidad de huéspedes, habitaciones, camas, baños, precio por noche, costo de limpieza, disponibilidad de Wi-Fi y espacio de parqueo).
* **Selección de Ubicación en Mapa:** Mapa interactivo basado en OpenStreetMap que permite desplazar, hacer zoom y fijar el marcador geográfico para registrar con precisión la `latitud` y `longitud` del alojamiento.
* **Galería y Subida de Fotografías:** Selección de imágenes desde la galería o cámara del dispositivo mediante `image_picker` y carga directa al servidor para mostrarlas en el catálogo de clientes.
* **Consulta de Reservas por Lugar:** Visualización de todas las reservas realizadas por los clientes en cada alojamiento, detallando fechas de entrada/salida, datos del huésped y montos totales.

---

## Stack Tecnológico

| Tecnología / Paquete | Uso |
| :--- | :--- |
| **Flutter & Dart** | Framework móvil multiplataforma y lenguaje principal |
| **OpenStreetMap (`flutter_map`)** | Mapa interactivo para seleccionar coordenadas geográficas |
| **`image_picker`** | Selección y captura de fotografías desde el dispositivo |
| **`shared_preferences`** | Almacenamiento local para mantener la sesión del anfitrión |
| **API REST (JSON / Multipart)** | Comunicación con el backend compartido y subida de imágenes |

---

## Estructura General del Proyecto

```text
lib/
├── main.dart      # Punto de entrada, tema y verificación de sesión
├── core/          # Constantes y configuración base de la aplicación
├── models/        # Modelos de datos: Arrendatario, Lugar, Foto, Reserva
├── providers/     # Gestión de estado de la aplicación
├── services/      # Consumo de API REST, autenticación y subida de archivos
├── screens/       # Pantallas: Login, Registro, Mis Lugares, Formulario/Mapa, Fotos, Reservas
└── widgets/       # Componentes reutilizables de la interfaz
```

---

## API Compartida

* **URL Base:** `https://api.airbnbmob2.online/api`

Módulos consumidos por la aplicación del arrendatario:
* **Autenticación:** Login y registro de arrendatarios.
* **Lugares:** Consulta de lugares por arrendatario, creación, edición y obtención de detalle.
* **Fotografías:** Carga de imágenes (`multipart/form-data`) asociadas a un lugar.
* **Reservas:** Consulta de reservas registradas por cada alojamiento.

---

## Instalación y Ejecución

### Requisitos previos
* [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado y configurado en el `PATH`
* Android Studio con Android SDK (API 35) y un emulador configurado o dispositivo físico con depuración USB

### 1. Clonar el repositorio e instalar dependencias

```bash
git clone <URL_DEL_REPOSITORIO>
cd airbnb_arrendatario
flutter pub get
```

### 2. Verificar permisos en Android

Confirmar que `android/app/src/main/AndroidManifest.xml` incluya el permiso de acceso a red antes de la etiqueta `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### 3. Ejecutar en emulador o dispositivo Android

```bash
# Listar dispositivos/emuladores disponibles
flutter devices

# Ejecutar la aplicación en el emulador seleccionado
flutter run -d <DEVICE_ID>
```

### 4. Generar APK de producción (opcional)

```bash
flutter build apk --release
```

El archivo generado quedará en `build/app/outputs/flutter-apk/app-release.apk`.
