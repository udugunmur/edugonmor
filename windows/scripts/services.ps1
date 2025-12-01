#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Script de gestión de servicios para Windows.
.DESCRIPTION
    Permite habilitar/deshabilitar servicios de Windows según perfiles predefinidos.
.NOTES
    Ejecutar como Administrador
#>

param(
    [Parameter()]
    [ValidateSet("list", "disable-bloat", "enable-all", "status")]
    [string]$Action = "status"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  edugonmor-windows - Servicios        " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Servicios considerados bloatware/innecesarios para desarrollo
$bloatServices = @(
    @{ Name = "DiagTrack"; Description = "Connected User Experiences and Telemetry" },
    @{ Name = "dmwappushservice"; Description = "WAP Push Message Routing Service" },
    @{ Name = "MapsBroker"; Description = "Downloaded Maps Manager" },
    @{ Name = "lfsvc"; Description = "Geolocation Service" },
    @{ Name = "SharedAccess"; Description = "Internet Connection Sharing" },
    @{ Name = "RemoteRegistry"; Description = "Remote Registry" },
    @{ Name = "RetailDemo"; Description = "Retail Demo Service" },
    @{ Name = "WMPNetworkSvc"; Description = "Windows Media Player Network Sharing" },
    @{ Name = "XblAuthManager"; Description = "Xbox Live Auth Manager" },
    @{ Name = "XblGameSave"; Description = "Xbox Live Game Save" },
    @{ Name = "XboxNetApiSvc"; Description = "Xbox Live Networking Service" }
)

function Show-ServiceStatus {
    Write-Host "Estado actual de servicios monitoreados:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host ("{0,-25} {1,-15} {2,-40}" -f "Servicio", "Estado", "Descripción") -ForegroundColor White
    Write-Host ("-" * 80)
    
    foreach ($svc in $bloatServices) {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($service) {
            $status = $service.Status
            $color = if ($status -eq "Running") { "Green" } else { "Gray" }
            Write-Host ("{0,-25} {1,-15} {2,-40}" -f $svc.Name, $status, $svc.Description) -ForegroundColor $color
        }
        else {
            Write-Host ("{0,-25} {1,-15} {2,-40}" -f $svc.Name, "No encontrado", $svc.Description) -ForegroundColor DarkGray
        }
    }
}

function Disable-BloatServices {
    Write-Host "Deshabilitando servicios innecesarios..." -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($svc in $bloatServices) {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($service) {
            try {
                if ($service.Status -eq "Running") {
                    Stop-Service -Name $svc.Name -Force -ErrorAction Stop
                }
                Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction Stop
                Write-Host "  [OK] $($svc.Name): Deshabilitado" -ForegroundColor Green
            }
            catch {
                Write-Host "  [ERROR] $($svc.Name): No se pudo deshabilitar" -ForegroundColor Red
            }
        }
    }
}

function Enable-AllServices {
    Write-Host "Habilitando servicios (restaurando valores predeterminados)..." -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($svc in $bloatServices) {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($service) {
            try {
                Set-Service -Name $svc.Name -StartupType Manual -ErrorAction Stop
                Write-Host "  [OK] $($svc.Name): Habilitado (Manual)" -ForegroundColor Green
            }
            catch {
                Write-Host "  [ERROR] $($svc.Name): No se pudo habilitar" -ForegroundColor Red
            }
        }
    }
}

function Show-AllServices {
    Write-Host "Listado de todos los servicios del sistema:" -ForegroundColor Yellow
    Write-Host ""
    Get-Service | Sort-Object Status, Name | Format-Table -AutoSize
}

switch ($Action) {
    "status" { Show-ServiceStatus }
    "list" { Show-AllServices }
    "disable-bloat" { Disable-BloatServices }
    "enable-all" { Enable-AllServices }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Operación completada                 " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Uso: .\services.ps1 -Action [status|list|disable-bloat|enable-all]" -ForegroundColor Gray
Write-Host ""
