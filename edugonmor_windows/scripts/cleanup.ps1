<#
.SYNOPSIS
    Script de limpieza de archivos temporales para Windows.
.DESCRIPTION
    Elimina archivos temporales, caché y otros archivos innecesarios.
.NOTES
    Puede ejecutarse sin permisos de administrador para limpieza básica.
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  edugonmor-windows - Limpieza         " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$totalFreed = 0

# ===== ARCHIVOS TEMPORALES DEL USUARIO =====
Write-Host "[PASO 1] Limpiando archivos temporales del usuario..." -ForegroundColor Yellow

$tempPaths = @(
    "$env:TEMP",
    "$env:LOCALAPPDATA\Temp",
    "$env:USERPROFILE\AppData\Local\Microsoft\Windows\INetCache",
    "$env:USERPROFILE\AppData\Local\Microsoft\Windows\Explorer"
)

foreach ($path in $tempPaths) {
    if (Test-Path $path) {
        $size = (Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        $sizeMB = [math]::Round($size / 1MB, 2)
        
        Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | 
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } |
            Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        
        $totalFreed += $size
        Write-Host "  - $path : ~$sizeMB MB" -ForegroundColor Green
    }
}

# ===== ARCHIVOS TEMPORALES DEL SISTEMA =====
Write-Host ""
Write-Host "[PASO 2] Limpiando archivos temporales del sistema..." -ForegroundColor Yellow

$systemTempPaths = @(
    "C:\Windows\Temp",
    "C:\Windows\Prefetch"
)

foreach ($path in $systemTempPaths) {
    if (Test-Path $path) {
        $size = (Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        $sizeMB = [math]::Round($size / 1MB, 2)
        
        Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | 
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } |
            Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        
        $totalFreed += $size
        Write-Host "  - $path : ~$sizeMB MB" -ForegroundColor Green
    }
}

# ===== PAPELERA DE RECICLAJE =====
Write-Host ""
Write-Host "[PASO 3] Vaciando papelera de reciclaje..." -ForegroundColor Yellow

try {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Host "  - Papelera: Vaciada" -ForegroundColor Green
}
catch {
    Write-Host "  - Papelera: No se pudo vaciar (puede estar vacía)" -ForegroundColor Yellow
}

# ===== CACHÉ DE DNS =====
Write-Host ""
Write-Host "[PASO 4] Limpiando caché de DNS..." -ForegroundColor Yellow

Clear-DnsClientCache -ErrorAction SilentlyContinue
Write-Host "  - Caché DNS: Limpiada" -ForegroundColor Green

# ===== RESUMEN =====
$totalFreedMB = [math]::Round($totalFreed / 1MB, 2)
$totalFreedGB = [math]::Round($totalFreed / 1GB, 2)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Limpieza completada                  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Espacio liberado aproximado: $totalFreedMB MB ($totalFreedGB GB)" -ForegroundColor Green
Write-Host ""
