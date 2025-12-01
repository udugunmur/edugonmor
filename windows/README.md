# windows

Scripts de configuración y optimización para sistemas Windows.

## 📋 Descripción

Este repositorio contiene scripts PowerShell para configurar y optimizar sistemas Windows según las necesidades de un entorno de desarrollo profesional.

## 📂 Estructura del Proyecto

```
windows/
├── agent.md         # Protocolo del agente
├── README.md        # Este archivo
├── Makefile         # Comandos de automatización
├── .gitignore       # Exclusiones de Git
├── config/          # Archivos de configuración
├── docs/            # Documentación detallada
├── scripts/         # Scripts PowerShell
└── tests/           # Tests de verificación
```

## 🚀 Características

### Optimización del Sistema
- Configuración de rendimiento de CPU
- Gestión de servicios innecesarios
- Optimización de inicio de Windows
- Limpieza de archivos temporales

### Configuración de Privacidad
- Deshabilitación de telemetría
- Configuración de Windows Defender
- Políticas de privacidad

### Mantenimiento
- Scripts de limpieza automática
- Verificación de configuración
- Gestión de actualizaciones

## 🛠️ Requisitos

- Windows 10/11 Pro o Enterprise
- PowerShell 5.1 o superior
- Permisos de administrador

## 📦 Uso Rápido

### 1. Clonar el repositorio

```powershell
git clone https://github.com/edugonmor/windows.git
cd windows
```

### 2. Habilitar ejecución de scripts

```powershell
# Ejecutar como Administrador
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 3. Ejecutar configuración inicial

```powershell
# Ejecutar como Administrador
.\scripts\setup.ps1
```

### 4. Verificar configuración

```powershell
.\tests\verify.ps1
```

## 📖 Documentación

La documentación detallada se encuentra en `docs/`:

- Configuración inicial del sistema
- Optimización de rendimiento
- Guía de scripts

## 🔧 Scripts Disponibles

| Script | Descripción |
|--------|-------------|
| `setup.ps1` | Configuración inicial del sistema |
| `optimize.ps1` | Optimización de rendimiento |
| `cleanup.ps1` | Limpieza de archivos temporales |
| `services.ps1` | Gestión de servicios de Windows |

## 📊 Estado

| Componente | Estado |
|------------|--------|
| Scripts | ✅ Implementado |
| Documentación | 🔄 En progreso |
| Tests | 🔄 En progreso |

## 🔗 Repositorios Relacionados

- `ubuntu` - Configuración de Ubuntu
- `tools` - Gestión de Docker/Portainer
- `rclone` - Backup con Rclone

## 📝 Licencia

MIT License

---

**Repositorio:** `/home/edugonmor/repos/windows`  
**Última actualización:** 29 de noviembre de 2025
