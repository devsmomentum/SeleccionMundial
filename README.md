# Mundial 2026 Picks

Aplicación kiosko en Flutter que permite a cada participante elegir sus **16 selecciones favoritas** para el Mundial 2026. Al confirmar, recibe un correo de confirmación con su lista agrupada por grupo/confederación.

---

## Flujo de usuario

1. La pantalla principal muestra todas las selecciones clasificadas al Mundial, organizadas por confederación.
2. El participante elige exactamente **16 países** tocando sus tarjetas.
3. Al completar la selección, presiona **Confirmar** → ingresa su correo → ve un resumen de sus picks.
4. Se envía un email HTML con la lista y se regresa a la pantalla principal con el estado completamente limpio para el siguiente participante.

---

## Stack tecnológico

| Capa                   | Tecnología                                    |
| ---------------------- | --------------------------------------------- |
| Frontend               | Flutter 3 · Dart                              |
| Backend / Email        | Supabase Edge Functions (Deno) · Nodemailer 6 |
| Fuente de banderas     | `country_flags ^3.0.0` (SVG vectoriales)      |
| Animaciones            | `confetti ^0.8.0`                             |
| Tipografía             | `google_fonts ^6.2.1`                         |
| Autenticación Supabase | `supabase_flutter ^2.9.0`                     |

---

## Estructura del proyecto

```
mundial/
├── lib/
│   └── main.dart              # Toda la lógica y UI de la app
├── supabase/
│   └── functions/
│       └── send-confirmation/
│           └── index.ts       # Edge Function: envía el email de confirmación
├── pubspec.yaml
├── .gitignore
└── README.md
```

### Pantallas principales (`main.dart`)

| Widget                  | Rol                                                                            |
| ----------------------- | ------------------------------------------------------------------------------ |
| `HomeScreen`            | Pantalla principal — muestra confederaciones y gestiona el estado de selección |
| `_SeccionConfederacion` | Grilla de 6 columnas con tarjetas de países por confederación                  |
| `_PaisCard`             | Tarjeta individual: bandera vectorial + nombre + indicador de seleccionado     |
| `EmailCaptureScreen`    | Captura el correo, muestra resumen y dispara el Edge Function                  |

---

## Requisitos previos

- Flutter SDK `^3.10.3`
- Cuenta en [Supabase](https://supabase.com)
- Proveedor SMTP (Gmail, Resend, Brevo, etc.)

---

## Instalación y desarrollo

### 1. Variables de entorno

Las credenciales de Supabase **nunca se escriben directamente en el código**. Se inyectan en tiempo de compilación con `--dart-define`.

Copia el archivo de ejemplo y completa tus valores:

```bash
cp .env.example .env
```

`.env` está en `.gitignore` — nunca se sube al repositorio.

### 2. Correr la app

```bash
# Instalar dependencias
flutter pub get

# Modo debug (lee las vars desde .env manualmente o pásalas inline)
flutter run \
  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=tu-anon-key

# Build APK release para Android
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=tu-anon-key
```

> **Tip en VS Code**: agrega las variables en `.vscode/launch.json` bajo `"toolArgs"` para no tener que escribirlas cada vez:
> ```json
> {
>   "configurations": [{
>     "name": "mundial (debug)",
>     "request": "launch",
>     "type": "dart",
>     "toolArgs": [
>       "--dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co",
>       "--dart-define=SUPABASE_ANON_KEY=tu-anon-key"
>     ]
>   }]
> }
> ```

El APK release queda en `build/app/outputs/flutter-apk/app-release.apk`.

---


## Lógica de selección

- Se pueden seleccionar entre 1 y **16 países** (el límite está definido por la constante `maxPicks = 16`).
- El botón "Confirmar" solo se activa cuando hay exactamente 16 seleccionados.
- Al volver de `EmailCaptureScreen` con `success = true`, el estado se limpia via `Navigator.push<bool>()` — listo para el siguiente participante.

---

## Email de confirmación

El Edge Function genera un correo HTML con:

- Encabezado con gradiente rojo
- Lista de los 16 países seleccionados, agrupados y ordenados por grupo
- Badge de grupo por cada selección
- Footer con nombre de la app
Para compilar apk .\build.bat