<#
.SYNOPSIS
    Script de verificación de configuración para Windows.
.DESCRIPTION
    Verifica que la configuración del sistema esté correctamente aplicada.
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  edugonmor-windows - Verificación     " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$testsPassed = 0
$testsFailed = 0

function Test-Config {
    param(
        [string]$Name,
        [scriptblock]$Test,
        [string]$Expected
    )
    
    try {
        $result = & $Test
        if ($result -eq $Expected -or $result -eq $true) {
            Write-Host "[PASS] $Name" -ForegroundColor Green
            $script:testsPassed++
        }
        else {
            Write-Host "[FAIL] $Name (Esperado: $Expected, Actual: $result)" -ForegroundColor Red
            $script:testsFailed++
        }
    }
    catch {
        Write-Host "[ERROR] $Name - $($_.Exception.Message)" -ForegroundColor Yellow
        $script:testsFailed++
    }
}

Write-Host "Verificando configuración del sistema..." -ForegroundColor Yellow
Write-Host ""

# ===== TESTS DE ENERGÍA =====
Write-Host "--- Configuración de Energía ---" -ForegroundColor Cyan

Test-Config -Name "Plan de energía activo" -Test {
    $plan = powercfg /getactivescheme
    $plan -match "Alto rendimiento|High performance"
} -Expected $true

Test-Config -Name "Hibernación desactivada" -Test {
    $hibFile = "C:\hiberfil.sys"
    -not (Test-Path $hibFile)
} -Expected $true

# ===== TESTS DE SERVICIOS =====
Write-Host ""
Write-Host "--- Servicios del Sistema ---" -ForegroundColor Cyan

$servicesToCheck = @("DiagTrack", "dmwappushservice")
foreach ($svc in $servicesToCheck) {
    Test-Config -Name "Servicio $svc deshabilitado" -Test {
        $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if ($service) {
            $service.StartType -eq "Disabled"
        }
        else {
            $true  # Si no existe, consideramos que está bien
        }
    } -Expected $true
}

# ===== TESTS DE SISTEMA =====
Write-Host ""
Write-Host "--- Sistema Operativo ---" -ForegroundColor Cyan

Test-Config -Name "Windows 10/11 detectado" -Test {
    $os = Get-CimInstance Win32_OperatingSystem
    $os.Caption -match "Windows 10|Windows 11"
} -Expected $true

Test-Config -Name "PowerShell 5.1+" -Test {
    $PSVersionTable.PSVersion.Major -ge 5
} -Expected $true

# ===== TESTS DE RED =====
Write-Host ""
Write-Host "--- Configuración de Red ---" -ForegroundColor Cyan

Test-Config -Name "Conectividad a Internet" -Test {
    Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet
} -Expected $true

# ===== RESUMEN =====
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Resumen de Verificación              " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Tests pasados: $testsPassed" -ForegroundColor Green
Write-Host "Tests fallidos: $testsFailed" -ForegroundColor $(if ($testsFailed -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "✓ Todas las verificaciones pasaron correctamente." -ForegroundColor Green
    exit 0
}
else {
    Write-Host "✗ Algunas verificaciones fallaron. Revisa la configuración." -ForegroundColor Yellow
    exit 1
}
