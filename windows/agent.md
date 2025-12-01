# Protocolo de Agente - windows

## Identidad del Proyecto

**Nombre:** windows  
**Tipo:** Scripts de Configuración y Optimización de Sistema Operativo  
**Plataforma:** Windows 10/11  
**Lenguaje:** PowerShell 5.1+

## Estructura del Proyecto

```
windows/
├── agent.md              # Este archivo - Protocolo del agente
├── README.md             # Documentación principal
├── Makefile              # Comandos de automatización (via WSL/Git Bash)
├── .gitignore            # Exclusiones de Git
├── config/               # Archivos de configuración
├── docs/                 # Documentación detallada
├── scripts/              # Scripts PowerShell
│   ├── setup.ps1         # Configuración inicial
│   ├── optimize.ps1      # Optimización del sistema
│   ├── cleanup.ps1       # Limpieza de sistema
│   └── services.ps1      # Gestión de servicios
└── tests/                # Tests de verificación
```

## Objetivo del Repositorio

Proporcionar scripts PowerShell para configurar y optimizar sistemas Windows para entornos de desarrollo, enfocándose en:

- Configuración inicial del sistema
- Optimización de rendimiento
- Deshabilitación de servicios innecesarios
- Limpieza de archivos temporales
- Configuración de privacidad

## Reglas de Operación

### Convenciones de Código

1. **PowerShell**: Usar PowerShell 5.1+ compatible
2. **Encoding**: UTF-8 con BOM para scripts .ps1
3. **Comentarios**: En español
4. **Nombres**: PascalCase para funciones, kebab-case para archivos

### Ejecución de Scripts

```powershell
# Habilitar ejecución de scripts (como Administrador)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Ejecutar script
.\scripts\setup.ps1
```

### Verificación

Antes de cualquier modificación:

```powershell
# Verificar estado actual
.\tests\verify.ps1
```

## Comandos Principales

| Comando | Descripción |
|---------|-------------|
| `.\scripts\setup.ps1` | Configuración inicial del sistema |
| `.\scripts\optimize.ps1` | Aplicar optimizaciones |
| `.\scripts\cleanup.ps1` | Limpiar archivos temporales |
| `.\scripts\services.ps1` | Deshabilitar servicios innecesarios |
| `.\tests\verify.ps1` | Verificar configuración |

## Flujo de Trabajo

### Para aplicar configuración

1. Abrir PowerShell como Administrador
2. Navegar al directorio del proyecto
3. Ejecutar `.\scripts\setup.ps1`
4. Verificar con `.\tests\verify.ps1`

### Para crear nuevo script

1. Crear archivo en `scripts/` con extensión `.ps1`
2. Incluir comentarios de uso en español
3. Documentar en `docs/`
4. Crear test correspondiente en `tests/`

## Restricciones

1. **NO modificar** registro de Windows sin backup previo
2. **NO deshabilitar** Windows Update permanentemente
3. **NO ejecutar** sin privilegios de administrador
4. **SIEMPRE** crear punto de restauración antes de cambios mayores

## Integración

Este repositorio es parte del ecosistema edugonmor:

- `ubuntu`: Configuración de Ubuntu
- `tools`: Gestión de Docker/Portainer
- `rclone`: Backup con Rclone

## Cierre de Ciclo

Antes de dar por completada una tarea:

1. ✅ Script creado/modificado funciona correctamente
2. ✅ Documentación actualizada
3. ✅ Test de verificación pasa
4. ✅ Sin errores en ejecución
5. ✅ Cambios commiteados
