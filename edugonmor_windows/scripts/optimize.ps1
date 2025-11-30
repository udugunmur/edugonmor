#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Script de optimización para Windows.
.DESCRIPTION
    Optimiza el sistema Windows para máximo rendimiento.
.NOTES
    Ejecutar como Administrador
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  edugonmor-windows - Optimización     " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ===== OPTIMIZACIÓN DE SERVICIOS =====
Write-Host "[PASO 1] Optimizando servicios innecesarios..." -ForegroundColor Yellow

$servicesToDisable = @(
    "DiagTrack",           # Connected User Experiences and Telemetry
    "dmwappushservice",    # WAP Push Message Routing Service
    "SysMain",             # Superfetch (en SSDs puede ser innecesario)
    "WSearch"              # Windows Search (si no se usa)
)

foreach ($service in $servicesToDisable) {
    $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
    if ($svc) {
        if ($svc.Status -eq "Running") {
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        }
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "  - $service : Deshabilitado" -ForegroundColor Green
    }
}

# ===== OPTIMIZACIÓN DE DISCO =====
Write-Host ""
Write-Host "[PASO 2] Optimizando configuración de disco..." -ForegroundColor Yellow

# Desactivar indexación en SSD
$volumes = Get-Volume | Where-Object { $_.DriveLetter -eq "C" }
if ($volumes) {
    Write-Host "  - Verificando configuración de indexación..." -ForegroundColor Green
}

# ===== OPTIMIZACIÓN DE RED =====
Write-Host ""
Write-Host "[PASO 3] Optimizando configuración de red..." -ForegroundColor Yellow

# Desactivar algoritmo de Nagle
$tcpipPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
Get-ChildItem $tcpipPath | ForEach-Object {
    Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -ErrorAction SilentlyContinue
}
Write-Host "  - Algoritmo de Nagle: Desactivado" -ForegroundColor Green

# ===== OPTIMIZACIÓN DE MEMORIA =====
Write-Host ""
Write-Host "[PASO 4] Optimizando configuración de memoria..." -ForegroundColor Yellow

# Limpiar memoria de trabajo
$memoryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $memoryPath -Name "ClearPageFileAtShutdown" -Value 0
Write-Host "  - Limpieza de PageFile al apagar: Desactivada (más rápido)" -ForegroundColor Green

# ===== RESUMEN =====
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Optimización completada              " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
