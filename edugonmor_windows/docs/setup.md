# Configuración Inicial de Windows

Este documento describe los pasos para la configuración inicial del sistema Windows.

## Requisitos Previos

- Windows 10/11 Pro o Enterprise
- PowerShell 5.1 o superior
- Permisos de administrador

## Pasos de Configuración

### 1. Descargar el Repositorio

```powershell
git clone https://github.com/edugonmor/edugonmor_windows.git
cd edugonmor_windows
```

### 2. Ejecutar PowerShell como Administrador

1. Clic derecho en el menú Inicio
2. Seleccionar "Windows PowerShell (Administrador)" o "Terminal (Administrador)"

### 3. Permitir Ejecución de Scripts

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 4. Ejecutar Script de Configuración

```powershell
.\scripts\setup.ps1
```

## Configuraciones Aplicadas

### Plan de Energía
- Plan: Alto Rendimiento
- Suspensión: Desactivada
- Hibernación: Desactivada
- Apagado de pantalla: Desactivado

### Windows Update
- Horas activas: 8:00 - 23:00

### Privacidad
- Telemetría: Minimizada

### Rendimiento
- Efectos visuales: Optimizados para rendimiento

## Verificación

Para verificar que la configuración se aplicó correctamente:

```powershell
.\tests\verify.ps1
```

## Revertir Cambios

Para restaurar la configuración predeterminada, consulta la documentación de cada componente en Windows Settings.

## Solución de Problemas

### El script no se ejecuta
Verifica que tienes permisos de administrador y que la política de ejecución permite scripts.

### Errores de permisos
Algunos cambios requieren reiniciar el sistema para aplicarse completamente.
