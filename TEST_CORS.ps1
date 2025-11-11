# 🧪 TEST RÁPIDO CORS desde PowerShell

## ✅ Copia y pega esto en PowerShell:

```powershell
# Test 1: Health Check
Write-Host "📍 Test 1: Health Check..."
$health = Invoke-WebRequest -Uri "https://app-251110163530.azurewebsites.net/healthz" -Method GET
Write-Host "✅ Status: $($health.StatusCode)"
Write-Host ""

# Test 2: Compute API
Write-Host "📍 Test 2: Compute API (POST)..."
$body = @{
    vth = 5
    rth = 1000
    k = 0.6
    c = 0.85
} | ConvertTo-Json

$response = Invoke-WebRequest `
    -Uri "https://app-251110163530.azurewebsites.net/api/Compute" `
    -Method POST `
    -Headers @{"Content-Type" = "application/json"} `
    -Body $body

Write-Host "✅ Status: $($response.StatusCode)"
Write-Host "📊 Response:"
$response.Content | ConvertFrom-Json | Format-List

Write-Host ""
Write-Host "Si ves estos datos, tu backend funciona correctamente ✨"
Write-Host "El error en la app es CORS. Necesitas agregar CORS en Program.cs"
```

## 🎯 Qué significa cada resultado:

**Si Status = 200:**
- ✅ El backend responde correctamente
- ❌ Pero la app web aún da error → Es CORS (necesita habilitarse en C#)

**Si Status = 500:**
- ❌ Error en el backend
- Revisa logs de Azure

**Si no funciona:**
- ❌ Azure puede estar caído
- Verifica en: https://portal.azure.com

---

**DESPUES de ejecutar este test, haz los cambios en Program.cs y republica. Luego intenta en la app.**
