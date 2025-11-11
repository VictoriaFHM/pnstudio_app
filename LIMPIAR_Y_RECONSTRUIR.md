# 🧹 LIMPIAR CACHÉ Y RECONSTRUIR

## Ejecuta esto en PowerShell:

```powershell
cd c:\Users\LENOVO\pnstudio_app

# 1. Limpiar Flutter
flutter clean

# 2. Obtener dependencias
flutter pub get

# 3. Regenerar archivos generados
dart run build_runner build --delete-conflicting-outputs

# 4. (Opcional) Limpiar web
Remove-Item -Path "build\web" -Recurse -Force -ErrorAction SilentlyContinue

# 5. Reconstruir web
flutter build web

# 6. Ejecutar en development
flutter run -d web-server --web-port=55676
```

## Luego en el navegador:

1. **Abre**: `http://localhost:55676`
2. **Ctrl+Shift+Del** (limpiar caché del navegador)
3. **F5** (recarga)
4. Deberías ver las **2 imágenes** y el botón debería funcionar

---

## Si TODAVÍA no funciona:

1. **F12** (DevTools)
2. **Console tab**
3. Busca errores rojos
4. Comparte conmigo
