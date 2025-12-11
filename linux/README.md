# 🐧 linux

> **Configuración y Optimización del Sistema Linux**
>
> Repositorio de scripts y configuraciones para optimizar Linux como servidor de desarrollo.

## 📚 Sobre esta Documentación
- **`README.md` (Este archivo):** Manual técnico para **Humanos**. Explica uso y configuraciones.
- **`agent.md`:** Protocolo Maestro para **Agentes IA**. Define reglas de desarrollo y políticas.

---

# 👤 GUÍA DE USUARIO (Quick Start)

## 🚀 Quick Start

```bash
# 1. Clonar repositorio
git clone https://github.com/edugonmor/linux.git
cd linux

# 2. Ejecutar configuración inicial (requiere sudo)
sudo ./scripts/setup.sh

# 3. Verificar configuración
./scripts/verify.sh
```

## 🛠️ Comandos Comunes

| Comando | Descripción |
|---------|-------------|
| `make setup` | Ejecuta configuración inicial completa del sistema |
| `make setup-minimal` | Ejecuta solo configuración de energía |
| `make vnc` | Habilita servidor VNC (x11vnc) |
| `make rclone` | Instala rclone para sincronización cloud |
| `make samba` | Instala Samba para compartir archivos vía SMB |
| `make backup-onedrive` | Ejecuta backup de OneDrive a disco local |
| `make upload-gdrive` | Sube archivos locales a Google Drive (udugunmur@gmail.com) |
| `make chrome` | Instala Google Chrome desde repositorio oficial |
| `make verify` | Verifica estado de la configuración |
| `make status` | Muestra estado actual del sistema |
| `make stable` | Push a repositorio remoto |

---

# 🏗️ GUÍA DE ARQUITECTO Y MANTENEDOR

## 📐 Propósito

Este repositorio centraliza la configuración del sistema Linux para:
- Deshabilitar suspensión e hibernación
- Optimizar rendimiento de CPU
- Configurar servicios systemd
- Aplicar configuraciones de GNOME

## 🗺️ Estructura del Proyecto

```text
linux/
├── scripts/                      # 🔧 Scripts de configuración
│   ├── setup.sh                  # Orquestador: configuración inicial
│   ├── verify.sh                 # Verificación completa del sistema
│   │
│   ├── system/                   # 📦 Configuración del sistema
│   │   └── configure-power-management.sh  # CPU, suspensión y sysctl
│   │
│   ├── install/                  # 📥 Instalación de software
│   │   ├── install-chrome.sh     # Google Chrome
│   │   ├── install-rclone.sh     # rclone para cloud sync
│   │   └── configure-vnc-server.sh  # Servidor VNC (x11vnc)
│   │
│   ├── backup/                   # 💾 Scripts de backup
│   │   ├── backup-onedrive.sh    # Backup de OneDrive
│   │   └── upload-gdrive.sh      # Subida a Google Drive
│   │
│   └── desktop/                  # 🖥️ Configuración de escritorio
│       └── configure-gnome-desktop.sh  # Ajustes GNOME
│
├── config/                       # ⚙️ Archivos de configuración
│   └── cpu-performance.service   # Servicio systemd para CPU
│
├── docs/                         # 📖 Documentación
│   └── CONFIGURATION.md          # Guía detallada de configuración
│
├── .gitignore
├── agent.md                      # 🤖 Protocolo para IA
├── Makefile                      # 🕹️ Comandos de automatización
└── README.md                     # 📚 Este archivo
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

### 9. Subida a Google Drive

Script para subir archivos locales a Google Drive (subida única, sin sincronización continua).

| Aspecto | Valor |
|---------|-------|
| Origen | `/mnt/disk2/rclone/oneDrive/edugonmor/` |
| Destino | `gdrive-udugunmur:` (raíz de Google Drive) |
| Cuenta | `udugunmur@gmail.com` |
| Config rclone | `/home/edugonmor/repos/edugonmor/rclone/docker/config/rclone.conf` |
| Método | `rclone copy` (no borra archivos en destino) |
| Características | Confirmación interactiva, verificación de espacio, progreso en tiempo real |

- **Comando:** `make upload-gdrive`
- **Documentación:** https://rclone.org/drive/

### 10. Compartición de Archivos (Samba/SMB)

Servidor Samba para acceder a los discos de Linux desde macOS vía Finder.

| Aspecto | Valor |
|---------|-------|
| Protocolo | SMB/CIFS |
| Puerto | 445 |
| Servicios | `smbd`, `nmbd` |
| Config | `/etc/samba/smb.conf` |
| Logs | `/var/log/samba/` |

**Shares configurados:**

| Share | Ruta | Descripción |
|-------|------|-------------|
| `home` | `/home/edugonmor` | Directorio de usuario |
| `disk1` | `/mnt/disk1` | Disco adicional 1 |
| `disk2` | `/mnt/disk2` | Disco adicional 2 |

**Conexión desde Mac:**

```bash
# Opción 1: Finder
# Ir → Conectar al servidor... (⌘K)
# smb://192.168.1.233

# Opción 2: Terminal
open smb://192.168.1.233
```

- **Comando:** `make samba`
- **Documentación:** https://www.samba.org/samba/docs/

### 11. Google Chrome

Navegador web instalado desde el repositorio oficial de Google.

| Aspecto | Valor |
|---------|-------|
| Versión | Stable (última estable) |
| Método de instalación | Repositorio APT oficial de Google |
| Ubicación binario | `/usr/bin/google-chrome` |
| Repositorio | `https://dl.google.com/linux/chrome/deb/` |
| Clave GPG | `/etc/apt/keyrings/google-chrome.gpg` |
| Lista sources | `/etc/apt/sources.list.d/google-chrome.list` |
| Auto-actualización | Sí (vía `apt upgrade`) |

- **Comando:** `make chrome`
- **Documentación:** https://www.google.com/linuxrepositories/

**Comandos útiles:**
```bash
# Abrir Chrome
google-chrome

# Ver versión instalada
google-chrome --version

# Actualizar Chrome
sudo apt update && sudo apt upgrade google-chrome-stable
```

## 📊 Resumen de Estado

| Parámetro | Valor | Descripción |
|-----------|-------|-------------|
| **Bloqueo de pantalla** | `false` | Deshabilitado |
| **Salvapantallas** | `false` | Deshabilitado |
| **Tiempo inactividad** | `0` | Nunca se activa |
| **Suspensión** | `masked` | Completamente bloqueada |
| **CPU Governor** | `performance` | Máximo rendimiento |
| **Inicio automático** | `enabled` | Servicio cpu-performance.service |
| **Google Chrome** | `stable` | Repositorio oficial de Google |

## 📚 Documentación de Referencia

- **Linux/Ubuntu Server**: https://ubuntu.com/server/docs
- **systemd**: https://www.freedesktop.org/software/systemd/man/
- **GNOME gsettings**: https://help.gnome.org/admin/system-admin-guide/stable/gsettings.html
- **rclone**: https://rclone.org/docs/
- **Google Chrome Linux**: https://www.google.com/linuxrepositories/

---

**Repositorio:** `/home/edugonmor/repos/edugonmor/linux`  
**Última actualización:** 1 de diciembre de 2025
