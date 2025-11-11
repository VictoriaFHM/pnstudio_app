# 🔧 Guía de Diagnóstico de Problemas de Red

## ❌ Error: "DioException [connection error]: XMLHttpRequest onError"

### Causas Comunes:

1. **CORS bloqueado** — El backend no acepta requests desde tu dominio
2. **Backend no alcanzable** — La URL está mal o el servicio no corre
3. **Protocolo mismatch** — Intentas HTTPS desde HTTP local (o viceversa)
4. **Timeout** — El backend tarda demasiado en responder

---

## ✅ Soluciones

### **Opción 1: Usar Backend Local (RECOMENDADO para desarrollo)**

Si tu API corre en `localhost:5230`:

1. Abre: `lib/env/env_dev.dart`
2. Verifica:
   ```dart
   static const baseUrl = 'http://localhost:5230';
   ```
3. Reinicia la app (`flutter run` o recarga en web)

**Ventaja**: Sin CORS, conexión local más rápida.

---

### **Opción 2: Usar Backend en Azure**

Si quieres usar `https://app-251110163530.azurewebsites.net`:

1. Abre: `lib/env/env_dev.dart`
2. Cambia a:
   ```dart
   static const baseUrl = 'https://app-251110163530.azurewebsites.net';
   ```
3. Asegúrate que el **backend tiene CORS habilitado**:
   - En C# / .NET, agregar a `Program.cs`:
     ```csharp
     builder.Services.AddCors(options =>
     {
         options.AddPolicy("AllowAll", policy =>
         {
             policy.AllowAnyOrigin()
                   .AllowAnyMethod()
                   .AllowAnyHeader();
         });
     });
     
     var app = builder.Build();
     app.UseCors("AllowAll");
     ```

---

### **Opción 3: Debug en DevTools**

1. Abre **Chrome DevTools** (F12)
2. Ve a **Network** tab
3. Haz clic en "Calcular"
4. Busca el request a `/api/Compute`
5. **Anota:**
   - ¿Request llega? (vés "pending", "cancelled", o "failed"?)
   - ¿Status code? (si falla, qué code?)
   - ¿Headers de respuesta?

**Si ves "CORS error"** → El backend necesita CORS habilitado.

---

### **Opción 4: Test Rápido con curl (Terminal)**

Prueba si el backend responde:

```bash
# Linux/Mac
curl -X POST http://localhost:5230/api/Compute \
  -H "Content-Type: application/json" \
  -d '{"vth": 5, "rth": 1000}'

# PowerShell (Windows)
$body = @{vth=5; rth=1000} | ConvertTo-Json
Invoke-WebRequest -Uri "http://localhost:5230/api/Compute" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body $body
```

Si funciona → El problema es CORS en web.
Si no funciona → El backend no está levantado.

---

## 📋 Checklist Rápido

- [ ] ¿Backend está corriendo? (test con curl)
- [ ] ¿URL es correcta en `env_dev.dart`?
- [ ] ¿Protocolo es HTTP (local) o HTTPS (remoto)?
- [ ] ¿Backend tiene CORS? (si es remoto)
- [ ] ¿Timeouts? (aumenta en `http_client.dart`)

---

## 🛠️ Cambios Hechos (Nov 10, 2025)

✅ Agregado sistema multi-ambiente (dev/prod)
✅ Interceptor personalizado para debug
✅ Convertir HTTPS → HTTP en localhost
✅ Headers CORS añadidos
✅ Timeouts aumentados (15s connect, 30s receive)

Ahora deberías ver **logs detallados en consola** cuando intentes calcular. 📊
