@echo off
echo.
echo  Compilando Mundial 2026 Picks...
echo.

flutter build apk --release ^
  --dart-define=SUPABASE_URL=https://algenenteukpflfcvkfp.supabase.co ^
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFsZ2VuZW50ZXVrcGZsZmN2a2ZwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE3Mjc2NDMsImV4cCI6MjA5NzMwMzY0M30.WoU7n9opaB8iOYAu4Oon83U436ZZ1B6C99ww16X91F0

if %ERRORLEVEL% == 0 (
  echo.
  echo  APK listo en:
  echo  build\app\outputs\flutter-apk\app-release.apk
  echo.
) else (
  echo.
  echo  Error en la compilacion.
  echo.
)

pause
