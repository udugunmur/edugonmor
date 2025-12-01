# 🐧 ubuntu

> **Configuración y Optimización del Sistema Ubuntu**
>
> Repositorio de scripts y configuraciones para optimizar Ubuntu como servidor de desarrollo.

## 📚 Sobre esta Documentación
- **`README.md` (Este archivo):** Manual técnico para **Humanos**. Explica uso y configuraciones.
- **`agent.md`:** Protocolo Maestro para **Agentes IA**. Define reglas de desarrollo y políticas.

---

# 👤 GUÍA DE USUARIO (Quick Start)

## 🚀 Quick Start

```bash
# 1. Clonar repositorio
git clone https://github.com/edugonmor/ubuntu.git
cd ubuntu

# 2. Ejecutar configuración inicial (requiere sudo)
sudo ./scripts/setup.sh

# 3. Verificar configuración
./scripts/verify.sh
```

## 🛠️ Comandos Comunes

| Comando | Descripción |
|---------|-------------|
| `make setup` | Ejecuta configuración inicial del sistema |
| `make optimize` | Optimiza rendimiento del sistema |
| `make vnc` | Habilita servidor VNC (x11vnc) |
| `make rclone` | Instala rclone para sincronización cloud |
| `make backup-onedrive` | Ejecuta backup de OneDrive a disco local |
| `make verify` | Verifica estado de la configuración |
| `make status` | Muestra estado actual del sistema |
| `make stable` | Push a repositorio remoto |

---

# 🏗️ GUÍA DE ARQUITECTO Y MANTENEDOR

## 📐 Propósito

Este repositorio centraliza la configuración del sistema Ubuntu para:
- Deshabilitar suspensión e hibernación
- Optimizar rendimiento de CPU
- Configurar servicios systemd
- Aplicar configuraciones de GNOME

## 🗺️ Estructura del Proyecto

```text
ubuntu/
├── scripts/                   # 🔧 Scripts de configuración
│   ├── setup.sh              # Configuración inicial completa
│   ├── optimize.sh           # Optimización de rendimiento
│   ├── disable-suspend.sh    # Deshabilitar suspensión
│   ├── cpu-performance.sh    # Modo performance de CPU
│   ├── verify.sh             # Verificación de configuración
│   ├── enable-vnc.sh         # Habilitar servidor VNC
│   ├── install-rclone.sh     # Instalación de rclone
│   └── backup-onedrive.sh    # Backup de OneDrive
│
├── config/                    # ⚙️ Archivos de configuración
│   ├── cpu-performance.service  # Servicio systemd para CPU
│   └── gnome-settings.sh     # Configuraciones de GNOME
│
├── docs/                      # 📖 Documentación
│   └── CONFIGURATION.md      # Guía detallada de configuración
│
├── .gitignore
├── agent.md                   # 🤖 Protocolo para IA
├── Makefile                   # 🕹️ Comandos de automatización
└── README.md                  # 📚 Este archivo
```

## ⚙️ Configuraciones Aplicadas

### 1. Suspensión e Hibernación (systemd)

```bash
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```
- **Estado:** `masked` (completamente bloqueado)

### 2. Configuración de GNOME (gsettings)

| Parámetro | Comando | Valor |
|-----------|---------|-------|
| Bloqueo de pantalla | `org.gnome.desktop.screensaver lock-enabled` | `false` |
| Salvapantallas | `org.gnome.desktop.screensaver idle-activation-enabled` | `false` |
| Tiempo inactividad | `org.gnome.desktop.session idle-delay` | `0` |
| Bloqueo permanente | `org.gnome.desktop.lockdown disable-lock-screen` | `true` |
| Suspensión AC | `org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type` | `'nothing'` |
| Suspensión batería | `org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type` | `'nothing'` |

### 3. Rendimiento de CPU

| Aspecto | Valor |
|---------|-------|
| Servicio systemd | `/etc/systemd/system/cpu-performance.service` |
| Estado | `enabled` (inicio automático) |
| Governor | `performance` |

### 4. Acceso Remoto (VNC)

Se utiliza `x11vnc` para permitir acceso remoto a la sesión de escritorio.

- **Servicio:** `x11vnc.service`
- **Puerto:** 5900
- **Wayland:** Deshabilitado (requerido para x11vnc)
- **Comando:** `make vnc`

### 5. Sincronización Cloud (rclone)

Herramienta para sincronizar archivos con servicios cloud (Google Drive, S3, etc.).

| Aspecto | Valor |
|---------|-------|
| Método de instalación | Script oficial (https://rclone.org/install/) |
| Ubicación binario | `/usr/bin/rclone` |
| Archivo de configuración | `~/.config/rclone/rclone.conf` |
| Auto-actualización | `sudo rclone selfupdate` |

- **Comando:** `make rclone`
- **Documentación:** https://rclone.org/docs/

### 6. Backup de OneDrive

Script para realizar backup manual de OneDrive a disco local.

| Aspecto | Valor |
|---------|-------|
| Remote | `onedrive-edugonmor:` |
| Destino | `/mnt/disk2/rclone/oneDrive/edugonmor/` |
| Logs | `/var/log/rclone/onedrive-backup-YYYYMMDD_HHMMSS.log` |
| Exclusiones | `Almacén personal` (Personal Vault) |
| Método | `rclone copy` (no borra archivos en destino) |

- **Comando:** `make backup-onedrive`
- **Documentación:** https://rclone.org/commands/rclone_copy/

## 📊 Resumen de Estado

| Parámetro | Valor | Descripción |
|-----------|-------|-------------|
| **Bloqueo de pantalla** | `false` | Deshabilitado |
| **Salvapantallas** | `false` | Deshabilitado |
| **Tiempo inactividad** | `0` | Nunca se activa |
| **Suspensión** | `masked` | Completamente bloqueada |
| **CPU Governor** | `performance` | Máximo rendimiento |
| **Inicio automático** | `enabled` | Servicio cpu-performance.service |

## 📚 Documentación de Referencia

- **Ubuntu Server**: https://ubuntu.com/server/docs
- **systemd**: https://www.freedesktop.org/software/systemd/man/
- **GNOME gsettings**: https://help.gnome.org/admin/system-admin-guide/stable/gsettings.html
- **rclone**: https://rclone.org/docs/

---

**Repositorio:** `/home/edugonmor/repos/edugonmor/ubuntu`  
**Última actualización:** 1 de diciembre de 2025
