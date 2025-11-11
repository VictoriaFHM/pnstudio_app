# 📋 GUÍA VISUAL: Qué Cambiar en Program.cs

## ❌ ANTES (Tu código actual - SIN CORS):

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();  // ← Aquí NO hay CORS

// --- Swagger UI ---
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
```

## ✅ DESPUÉS (CON CORS):

```csharp
var builder = WebApplication.CreateBuilder(args);

// ✅ AGREGAR ESTO AQUÍ (líneas nuevas):
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Services.AddControllers();  // ← DESPUÉS del CORS

// --- Swagger UI ---
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
```

---

## 🔧 Lo que cambió en la SEGUNDA PARTE:

### ❌ ANTES:

```csharp
var app = builder.Build();

// --- Swagger UI ---
app.UseSwagger();
// ...

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
```

### ✅ DESPUÉS:

```csharp
var app = builder.Build();

// ✅ AGREGAR ESTA LÍNEA (la primera después de builder.Build()):
app.UseCors("AllowAll");

// --- Swagger UI ---
app.UseSwagger();
// ...

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
```

---

## 📌 RESUMEN DE LOS CAMBIOS:

**3 secciones nuevas (copiar y pegar):**

1. **Línea ~11** (después de `CreateBuilder`):
   ```csharp
   builder.Services.AddCors(options =>
   {
       options.AddPolicy("AllowAll", policy =>
       {
           policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
       });
   });
   ```

2. **Línea ~35** (después de `builder.Build()`, ANTES de `app.UseSwagger()`):
   ```csharp
   app.UseCors("AllowAll");
   ```

---

## 🚀 DESPUÉS DE CAMBIAR:

1. **Guarda el archivo** (Ctrl+S en Rider)
2. **Build → Build** (o Ctrl+F9)
3. **Publish** a Azure
4. **Espera 2-3 minutos**
5. **Recarga la app web** (F5)
6. Intenta calcular → ✨ **¡Debería funcionar!**

---

## 📄 Archivo completo listo:

Ver: `Program_cs_WITH_CORS.cs` en esta carpeta (cópialo completo si quieres)

---

**¿Problemas?** Avísame qué líneas no entiendes y te lo explico. 💪
