# 🚀 SOLUCIÓN RÁPIDA: MODO MOCK PARA TESTEAR SIN BACKEND

## ⚡ TL;DR (lo importante):

Tu API backend **no está corriendo o no es alcanzable**. Mientras lo arreglas, puedes testear la app con **datos ficticios**.

---

## ✅ Solución Inmediata (2 segundos):

### 1. **Abre este archivo:**
```
lib/data/repositories/compute_repository.dart
```

### 2. **Busca esta línea (alrededor de la línea 13):**
```dart
static const bool useMockData = false; // 👈 CAMBIA AQUÍ
```

### 3. **Cambia `false` por `true`:**
```dart
static const bool useMockData = true; // ✅ AHORA USA DATOS FICTICIOS
```

### 4. **Guarda (Ctrl+S) y recarga el navegador**

### ✨ **¡Listo! Ahora debería funcionar sin errores.**

---

## 🧪 Qué pasa cuando usas Mock:

- ✅ La app calcula con **datos realistas ficticios**
- ✅ La gráfica P vs RL se dibuja correctamente
- ✅ Los rangos (RL min, RL max, etc.) se muestran
- ✅ **Sin necesidad de backend corriendo**

---

## 🔄 Cuando quieras volver a API Real:

1. Abre `lib/data/repositories/compute_repository.dart`
2. Cambia a `static const bool useMockData = false;`
3. Asegúrate que tu backend está corriendo en:
   - **Desarrollo**: `http://localhost:5230` (verificar en `lib/env/env_dev.dart`)
   - **Producción**: `https://app-251110163530.azurewebsites.net` (verificar en `lib/env/env_prod.dart`)

---

## 🛠️ Información Técnica

### Mock Repository genera:

```
- Vth y Rth: validadas (> 0)
- Pmax: calculado como V²/R
- k y c: default 0.6 y 0.85 si no se proporcionan
- RL min/max: rango alrededor de Rth
- η (eta): eficiencia entre 0.5 y 0.95
- P mínima: configurable
```

### Archivo Mock:
```
lib/data/network/mock_compute_repository.dart
```

Puedes **editarlo** si quieres cambiar los valores por defecto.

---

## 🎯 Plan para Arreglar el Backend Real:

1. **¿Dónde está tu API?** ¿Proyecto C# separado?
2. **¿Está corriendo?** Testea con:
   ```bash
   curl http://localhost:5230/api/Compute \
     -X POST \
     -H "Content-Type: application/json" \
     -d '{"vth": 5, "rth": 1000}'
   ```
3. **¿CORS habilitado?** Si es remoto, revisar `Program.cs` del backend

**Mientras tanto: ¡Usa Mock para testear la UI!** 🎉

---

**Creado**: Nov 10, 2025
**Autor**: GitHub Copilot (ayudando a resolver XMLHttpRequest errors 😅)
