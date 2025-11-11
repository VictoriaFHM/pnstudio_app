# 🔴 SOLUCIÓN: HABILITAR CORS EN BACKEND AZURE

## ⚙️ PASO 1: Edita tu Backend C# en Rider

### Abre: `Program.cs` (o `Startup.cs`)

Busca esta sección:
```csharp
// Tu código actual probablemente luce así:
var builder = WebApplicationBuilder.CreateBuilder(args);

// Agregar servicios
builder.Services.AddControllers();
builder.Services.AddOpenApi();

var app = builder.Build();
```

### Reemplaza por ESTO (con CORS habilitado):

```csharp
var builder = WebApplicationBuilder.CreateBuilder(args);

// ✅ AGREGAR CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()        // Permite cualquier origen
              .AllowAnyMethod()         // Permite GET, POST, etc.
              .AllowAnyHeader();        // Permite cualquier header
    });
});

// Agregar controladores
builder.Services.AddControllers();
builder.Services.AddOpenApi();

var app = builder.Build();

// ✅ USAR CORS ANTES de MapControllers
app.UseCors("AllowAll");

// Resto del código...
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
app.Run();
```

---

## ✅ PASO 2: Publish a Azure

1. En Rider, haz **Build → Publish**
2. Elige la configuración Azure
3. **Espera a que se publique** (~2-3 minutos)

---

## ✅ PASO 3: Testea desde la App

1. Ve a: `lib/env/env_dev.dart`
2. Asegúrate que diga:
   ```dart
   static const baseUrl = 'https://app-251110163530.azurewebsites.net';
   ```
3. En tu app Flutter Web, en `lib/data/repositories/compute_repository.dart`:
   ```dart
   static const bool useMockData = false; // ✅ Usa API real
   ```
4. **Recarga la página** (F5 en el navegador)
5. Intenta calcular → **¡Debería funcionar! ✨**

---

## 🧪 Verifica CORS desde Terminal

Antes de hacer cambios, prueba si CORS funciona:

```bash
# PowerShell en Windows
$headers = @{
    "Content-Type" = "application/json"
}
$body = @{vth=5; rth=1000} | ConvertTo-Json

Invoke-WebRequest -Uri "https://app-251110163530.azurewebsites.net/api/Compute" `
  -Method POST `
  -Headers $headers `
  -Body $body
```

Si ves el resultado JSON → CORS está OK.
Si ves error → Necesita la configuración de arriba.

---

## 📋 Checklist:

- [ ] Editaste `Program.cs` con `AddCors` y `UseCors`
- [ ] Hiciste Publish a Azure desde Rider
- [ ] Esperaste 2-3 minutos a que se publique
- [ ] Verificaste que `env_dev.dart` tiene la URL correcta
- [ ] Recargaste la página del navegador
- [ ] Pusiste `useMockData = false`
- [ ] Intentaste calcular

Si todavía no funciona, avísame qué ves en DevTools (F12 → Network tab).
