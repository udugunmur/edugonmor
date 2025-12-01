#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Script de configuración inicial para Windows.
.DESCRIPTION
    Configura el sistema Windows con las opciones óptimas para desarrollo.
.NOTES
    Ejecutar como Administrador
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  edugonmor-windows - Setup Inicial    " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar permisos de administrador
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[ERROR] Este script requiere permisos de administrador." -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] Permisos de administrador verificados." -ForegroundColor Green

# ===== CONFIGURACIÓN DE ENERGÍA =====
Write-Host ""
Write-Host "[PASO 1] Configurando plan de energía..." -ForegroundColor Yellow

# Establecer plan de alto rendimiento
$highPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
powercfg /setactive $highPerfGuid
Write-Host "  - Plan de energía: Alto rendimiento" -ForegroundColor Green

# Desactivar suspensión
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0
Write-Host "  - Suspensión: Desactivada" -ForegroundColor Green

# Desactivar hibernación
powercfg /hibernate off
Write-Host "  - Hibernación: Desactivada" -ForegroundColor Green

# Desactivar apagado de pantalla
powercfg /change monitor-timeout-ac 0
powercfg /change monitor-timeout-dc 0
Write-Host "  - Apagado de pantalla: Desactivado" -ForegroundColor Green

# ===== CONFIGURACIÓN DE WINDOWS UPDATE =====
Write-Host ""
Write-Host "[PASO 2] Configurando Windows Update..." -ForegroundColor Yellow

# Configurar horas activas (8:00 - 23:00)
$registryPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
if (Test-Path $registryPath) {
    Set-ItemProperty -Path $registryPath -Name "ActiveHoursStart" -Value 8
    Set-ItemProperty -Path $registryPath -Name "ActiveHoursEnd" -Value 23
    Write-Host "  - Horas activas: 8:00 - 23:00" -ForegroundColor Green
}

# ===== CONFIGURACIÓN DE PRIVACIDAD =====
Write-Host ""
Write-Host "[PASO 3] Configurando privacidad..." -ForegroundColor Yellow

# Desactivar telemetría básica
$telemetryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (-not (Test-Path $telemetryPath)) {
    New-Item -Path $telemetryPath -Force | Out-Null
}
Set-ItemProperty -Path $telemetryPath -Name "AllowTelemetry" -Value 0
Write-Host "  - Telemetría: Minimizada" -ForegroundColor Green

# ===== CONFIGURACIÓN DE RENDIMIENTO =====
Write-Host ""
Write-Host "[PASO 4] Configurando rendimiento..." -ForegroundColor Yellow

# Desactivar efectos visuales innecesarios
$visualFxPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
if (-not (Test-Path $visualFxPath)) {
    New-Item -Path $visualFxPath -Force | Out-Null
}
Set-ItemProperty -Path $visualFxPath -Name "VisualFXSetting" -Value 2
Write-Host "  - Efectos visuales: Optimizados para rendimiento" -ForegroundColor Green

# ===== RESUMEN =====
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Configuración completada             " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Se recomienda reiniciar el sistema para aplicar todos los cambios." -ForegroundColor Yellow
Write-Host ""
